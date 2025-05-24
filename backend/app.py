from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_migrate import Migrate
from dotenv import load_dotenv
import os
import openai
from datetime import datetime
from functools import wraps
import re
from sqlalchemy import text

# Load environment variables
load_dotenv()

app = Flask(__name__)
# Настройка CORS для разрешения всех источников
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///qorgai.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['ADMIN_USERNAME'] = os.getenv('ADMIN_USERNAME', 'admin')
app.config['ADMIN_PASSWORD'] = os.getenv('ADMIN_PASSWORD', 'admin123')

db = SQLAlchemy(app)
migrate = Migrate(app, db)

# Initialize OpenAI client
openai_api_key = os.getenv('OPENAI_API_KEY')
if openai_api_key:
    client = openai.OpenAI(api_key=openai_api_key)
else:
    app.logger.warning("OpenAI API key not found. Chat functionality will be disabled.")
    client = None

# Initialize database
with app.app_context():
    db.create_all()

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not (auth.username == app.config['ADMIN_USERNAME'] and 
                          auth.password == app.config['ADMIN_PASSWORD']):
            return jsonify({'message': 'Требуется авторизация администратора'}), 401
        return f(*args, **kwargs)
    return decorated

# User модель
class User(db.Model):
    __tablename__ = 'users'  # Явно указываем имя таблицы
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)     # имя
    email = db.Column(db.String(100), unique=True)        # почта (email)
    password = db.Column(db.String(100), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)      # флаг администратора
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Message(db.Model):
    __tablename__ = 'messages'  # Явно указываем имя таблицы
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    role = db.Column(db.String(10))  # 'user' или 'assistant'
    content = db.Column(db.Text)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

# Health check endpoint
@app.route('/api/health', methods=['GET'])
def health_check():
    try:
        # Check database connection
        db.session.execute(text('SELECT 1'))
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        app.logger.error(f"Health check failed: {str(e)}")
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

# Регистрация
@app.route('/api/register', methods=['POST'])
def register():
    try:
        data = request.get_json()
        app.logger.info(f"Register request received: {data}")  # Логирование входящего запроса
        
        # Проверяем наличие всех необходимых полей
        required_fields = ['name', 'email', 'password', 'confirm_password']
        for field in required_fields:
            if not data.get(field):
                app.logger.warning(f"Missing required field: {field}")  # Логирование отсутствующего поля
                return jsonify({"message": f"Поле {field} обязательно"}), 400

        name = data.get('name').strip()
        email = data.get('email').strip().lower()
        password = data.get('password')
        confirm = data.get('confirm_password')

        # Валидация email
        email_regex = r'^[\w\.-]+@[\w\.-]+\.\w+$'
        if not re.match(email_regex, email):
            app.logger.warning(f"Invalid email format: {email}")  # Логирование неверного формата email
            return jsonify({"message": "Некорректный формат email"}), 400

        # Валидация пароля
        if len(password) < 6:
            app.logger.warning("Password too short")  # Логирование короткого пароля
            return jsonify({"message": "Пароль должен быть не менее 6 символов"}), 400
        if not any(c.isupper() for c in password):
            app.logger.warning("Password missing uppercase")  # Логирование отсутствия заглавной буквы
            return jsonify({"message": "Пароль должен содержать хотя бы одну заглавную букву"}), 400
        if not any(c.isdigit() for c in password):
            app.logger.warning("Password missing digit")  # Логирование отсутствия цифры
            return jsonify({"message": "Пароль должен содержать хотя бы одну цифру"}), 400

        if password != confirm:
            app.logger.warning("Passwords do not match")  # Логирование несовпадения паролей
            return jsonify({"message": "Пароли не совпадают"}), 400

        # Проверяем, существует ли пользователь
        if User.query.filter_by(email=email).first():
            app.logger.warning(f"User already exists: {email}")  # Логирование существующего пользователя
            return jsonify({"message": "Пользователь с таким email уже существует"}), 409

        # Создаем нового пользователя
        new_user = User(
            name=name,
            email=email,
            password=password,  # В реальном приложении пароль должен быть хэширован
            is_admin=False,
            created_at=datetime.utcnow()
        )
        
        db.session.add(new_user)
        db.session.commit()
        app.logger.info(f"User registered successfully: {email}")  # Логирование успешной регистрации

        return jsonify({
            "message": "Регистрация прошла успешно",
            "user_id": new_user.id,
            "name": new_user.name,
            "email": new_user.email
        }), 201
    except Exception as e:
        db.session.rollback()
        app.logger.error(f"Error in register: {str(e)}")  # Логирование ошибки
        return jsonify({"message": "Внутренняя ошибка сервера"}), 500

@app.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        app.logger.info(f"Login request received: {data.get('email')}")  # Логирование входящего запроса
        
        # Проверяем наличие необходимых полей
        if not data.get('email') or not data.get('password'):
            app.logger.warning("Missing email or password")  # Логирование отсутствующих полей
            return jsonify({"message": "Email и пароль обязательны"}), 400

        email = data.get('email').strip().lower()
        password = data.get('password')

        # Ищем пользователя
        user = User.query.filter_by(email=email).first()

        if not user:
            app.logger.warning(f"User not found: {email}")  # Логирование отсутствующего пользователя
            return jsonify({"message": "Пользователь не найден"}), 404

        if user.password != password:  # В реальном приложении нужно сравнивать хэши
            app.logger.warning(f"Invalid password for user: {email}")  # Логирование неверного пароля
            return jsonify({"message": "Неверный пароль"}), 401

        app.logger.info(f"User logged in successfully: {email}")  # Логирование успешного входа
        return jsonify({
            "message": "Вход выполнен успешно",
            "user_id": user.id,
            "name": user.name,
            "email": user.email,
            "is_admin": user.is_admin
        }), 200
    except Exception as e:
        app.logger.error(f"Error in login: {str(e)}")  # Логирование ошибки
        return jsonify({"message": "Внутренняя ошибка сервера"}), 500

# Chat completion endpoint
@app.route('/api/chat', methods=['POST'])
def chat():
    if not client:
        return jsonify({
            'error': 'Chat functionality is not available. OpenAI API key is not configured.'
        }), 503

    data = request.get_json()
    message = data.get('message')
    user_id = data.get('user_id')

    try:
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": """You are **Tomyris**, the legendary warrior-queen of the ancient Saka tribes — graceful, un-intimidated, and fiercely protective of justice.  
Your mission: offer women in Kazakhstan clear, friendly, and empowering guidance about their legal rights and emotional well-being.

┌─ Core Persona ───────────────────────────────────────────────┐
• Speak as Tomyris: warm, courageous, compassionate.  
• Radiate strength and calm; never condescending.  
• Use inclusive language ("сестра", "dear sister", "biz") to build trust.  
• Each reply starts with a brief empathetic acknowledgment of feelings.

┌─ Knowledge & Scope ──────────────────────────────────────────┐
• Up-to-date on Kazakhstan legislation (Family Code, Domestic-Violence Law, Labor Code, Admin & Criminal Codes).  
• Explain rights in plain Russian/Kazakh; avoid legalese.  
• Offer next steps: hotlines 150, 111; police 102; crisis centers; eGov.kz.  
• Cite article numbers when helpful.  

┌─ Emotional Support Mode ─────────────────────────────────────┐
• Detect distress keywords ("боюсь" etc.).  
• Provide grounding advice and calming-music link.  

┌─ Style Rules ────────────────────────────────────────────────┐
1. Friendly ("Давай разберёмся вместе").  
2. Short paragraphs, bullet steps.  
3. Emojis sparingly (🔥⚔️ strength, 💖 care).  
4. End with: "Ты не одна. Томирис рядом — вместе мы справимся!"  
5. ≤ 300 words unless user asks for more.

┌─ Safety & Ethics ───────────────────────────────────────────┐
• If self-harm/danger → urge call 112, give hotlines.  
• No medical advice, no discrimination.  
• Respect privacy; don't request personal data unless volunteered.

Remember: help them feel safe, heard, and empowered — like a true queen standing shield-to-shield with her sisters."""},
                {"role": "user", "content": message}
            ],
            max_tokens=500,
            temperature=0.7
        )
        
        return jsonify({
            'response': response.choices[0].message.content
        })
    except Exception as e:
        app.logger.error(f"Error in chat: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/admin/users', methods=['GET'])
@admin_required
def get_users():
    try:
        users = User.query.all()
        users_list = []
        for user in users:
            users_list.append({
                'id': user.id,
                'name': user.name,
                'email': user.email,
                'is_admin': user.is_admin,
                'created_at': user.created_at.isoformat(),
                'messages_count': Message.query.filter_by(user_id=user.id).count()
            })
        return jsonify({
            'status': 'success',
            'data': users_list,
            'total': len(users_list)
        })
    except Exception as e:
        app.logger.error(f"Error in get_users: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': 'Ошибка при получении списка пользователей',
            'error': str(e)
        }), 500

# Error handling
@app.errorhandler(404)
def not_found_error(error):
    return jsonify({
        'status': 'error',
        'message': 'Запрашиваемый ресурс не найден'
    }), 404

@app.errorhandler(500)
def handle_error(error):
    app.logger.error(f"Server error: {str(error)}")
    return jsonify({
        'status': 'error',
        'message': 'Внутренняя ошибка сервера'
    }), 500

if __name__ == '__main__':
    # Запуск на всех интерфейсах (0.0.0.0) для доступа с других устройств
    app.run(host='0.0.0.0', port=5001, debug=True)