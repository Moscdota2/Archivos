<?php

  require 'database.php';

  $message = '';

  if (!empty($_POST['email']) && !empty($_POST['password1'])) {
    $sql = "INSERT INTO usuarios (email, password1) VALUES (:email, :password1)";
    $stmt = $conn->prepare($sql);
    $stmt->bindParam(':email', $_POST['email']);
    $password = password_hash($_POST['password1'], PASSWORD_BCRYPT);
    $stmt->bindParam(':password', $password);

    if ($stmt->execute()) {
      $message = 'Usuario Creado Correctamente';
    } else {
      $message = 'Error al crear usuario';
    }
  }
?>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Registro</title>
    <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
    <link rel="stylesheet" href="html/css/vergas.css">
  </head>
  <body>

    <?php require 'partials/header.php' ?>

    <?php if(!empty($message)): ?>
      <p> <?= $message ?></p>
    <?php endif; ?>

    <h1>Registro</h1>
    <span>o <a href="login.php">inicia Sesion</a></span>

    <form action="registro.php" method="POST">
      <input name="email" type="text" placeholder="Ingresa tu Email">
      <input name="password1" type="password" placeholder="Ingresa tu Contraseña">
      <input name="confirm_password" type="password" placeholder="Confirma tu Contraseña">
      <input type="submit" value="Submit">
    </form>

  </body>
</html>