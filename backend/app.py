from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # для Flutter

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///qorgai.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# User модель

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)     # имя
    email = db.Column(db.String(100), unique=True)        # почта (email)
    password = db.Column(db.String(100), nullable=False)


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


if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)