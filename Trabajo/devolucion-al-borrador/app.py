from flask import Flask, render_template, url_for

app = Flask(__name__)

@app.route("/inicio")
def view_inicio():
    return render_template("index.html")

@app.route("/informacion")
def view_informacion():
    return render_template("info.html")

@app.route("/carga_datos")
def view_carga():
    return render_template("carga.html")

if __name__ == '__main__':
    app.run(debug=True)