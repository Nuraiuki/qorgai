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
def chat():
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
        return jsonify({'error': str(e)}), 500

# Error handling
@app.errorhandler(500)
def handle_error(error):
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    # Запуск на всех интерфейсах (0.0.0.0) для доступа с других устройств
    app.run(host='0.0.0.0', port=5000, debug=True)