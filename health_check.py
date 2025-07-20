from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def health_check():
    """
    A simple health check endpoint that returns a 200 OK response.
    """
    return jsonify(status="ok"), 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
