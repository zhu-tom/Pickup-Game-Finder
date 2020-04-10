<?php

require('./database.php');

$stmt = $conn->prepare("SELECT * FROM posts");
$stmt->execute();
$result = $stmt->fetchAll(PDO::FETCH_ASSOC);

for ($i = 0; $i < count($result); $i++) {
    $stmt = $conn->prepare("SELECT userToPost.user_id, userToPost.team_id, users.first_name, users.last_name, users.username FROM userToPost INNER JOIN users ON userToPost.user_id = users.id WHERE userToPost.post_id = ?");
    $stmt->bindParam(1, $result[$i]["id"]);
    $stmt->execute();
    $res = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $result[$i]['players'] = $res;
}

echo json_encode($result);

?>