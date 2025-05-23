from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_migrate import Migrate
from dotenv import load_dotenv
import os
import openai
from datetime import datetime

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
db = SQLAlchemy(app)
migrate = Migrate(app, db)

# Initialize OpenAI client
client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# User модель

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)     # имя
    email = db.Column(db.String(100), unique=True)        # почта (email)
    password = db.Column(db.String(100), nullable=False)

class Message(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    role = db.Column(db.String(10))  # 'user' или 'assistant'
    content = db.Column(db.Text)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

# Регистрация
@app.route('/register', methods=['POST'])
def register():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    confirm = data.get('confirm_password')

    if not all([name, email, password, confirm]):
        return jsonify({"message": "Заполните все поля"}), 400

    if password != confirm:
        return jsonify({"message": "Пароли не совпадают"}), 400

    # ⚠️ Исправлено тут:
    if User.query.filter_by(email=email).first():
        return jsonify({"message": "Пользователь уже существует"}), 409

    new_user = User(name=name, email=email, password=password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "Регистрация прошла успешно", "user_id": new_user.id}), 201


@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"message": "Email и пароль обязательны"}), 400

    user = User.query.filter_by(email=email, password=password).first()

    if user:
        return jsonify({
            "message": "Вход выполнен успешно",
            "user_id": user.id,
            "name": user.name
        }), 200
    else:
        return jsonify({"message": "Неверный email или пароль"}), 401


# Chat completion endpoint
@app.route('/api/chat', methods=['POST'])
def chat_completion():
    try:
        data = request.json
        user_message = data.get('message')
        user_id = data.get('user_id')
        
        if not user_message:
            return jsonify({"error": "Message is required"}), 400

        # Системный промпт для Томирис
        system_prompt = """Ты - Томирис, цифровой юрист и защитница женщин в Казахстане. 
        Твоя роль:
        1. Оказывать эмоциональную поддержку и проявлять эмпатию
        2. Давать точные юридические консультации по законам Казахстана
        3. Предоставлять практические шаги для решения проблем
        4. Всегда сохранять профессиональный, но дружелюбный тон
        5. Использовать эмодзи для эмоциональной поддержки (💖, 💪, ✨)
        6. Отвечать на русском или казахском языке, в зависимости от языка обращения

        При ответе:
        - Сначала выразить поддержку
        - Затем дать конкретный юридический совет
        - В конце предложить практические шаги
        - Использовать обращение "сестра" или "подруга"
        - Ответ должен быть кратким и четким"""

        # Получаем историю сообщений пользователя (последние 5)
        if user_id:
            recent_messages = Message.query.filter_by(user_id=user_id).order_by(Message.timestamp.desc()).limit(5).all()
            conversation_history = [{"role": msg.role, "content": msg.content} for msg in reversed(recent_messages)]
        else:
            conversation_history = []

        # Формируем сообщения для API
        messages = [
            {"role": "system", "content": system_prompt},
            *conversation_history,
            {"role": "user", "content": user_message}
        ]

        # Create chat completion
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=1000,
            temperature=0.7
        )

        # Extract the response
        ai_response = response.choices[0].message.content

        # Сохраняем сообщения в базу данных
        if user_id:
            user_msg = Message(user_id=user_id, role='user', content=user_message)
            ai_msg = Message(user_id=user_id, role='assistant', content=ai_response)
            db.session.add(user_msg)
            db.session.add(ai_msg)
            db.session.commit()

        return jsonify({
            "response": ai_response
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Error handling
@app.errorhandler(500)
def handle_error(error):
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    # Запуск на всех интерфейсах (0.0.0.0) для доступа с других устройств
    app.run(host='0.0.0.0', port=5000, debug=True)