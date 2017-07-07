<?php
$mysql_host = "";
$mysql_user = "";
$mysql_password = "";
$mysql_database = "";
$action = null;
$date = null;


if (isset($_GET["action"])) {
    $action = $_GET['action'];
}
if (isset($_GET["latitude"])) {
    $latitude = $_GET['latitude'];
}
if (isset($_GET["longitude"])) {
    $longitude = $_GET['longitude'];
}
if (isset($_GET["date"])) {
    $date = $_GET['date'];
}
if (isset($_GET["objectID"])) {
  $objectID = $_GET['objectID'];
}


mysql_connect($mysql_host, $mysql_user, $mysql_password);
mysql_select_db($mysql_database);
mysql_set_charset('utf8');
if($action == 'select'){
  if($date == null){
      $q=mysql_query("SELECT * FROM GpsData");
    }else{

      $q=mysql_query("SELECT * FROM GpsData WHERE date > $date");

}
    if(mysql_num_rows($q)>0){
      while($e=mysql_fetch_assoc($q))
            $output[]=$e;
      print(json_encode($output));
    }
    else {
      $arr = array(array("_id" => "0", "latitude" => "0", "longitude" => "0", "date" => "0", "objectID" => "0"));
      print(json_encode($arr));
    }
}


if($action == 'insert' && $latitude != null && $longitude != null && $objectID != null){

  $current_time = round(microtime(1) * 1000);
  mysql_query("INSERT INTO `GpsData`(`latitude`,`longitude`,`date`, `objectID`) VALUES ('$latitude','$longitude','$current_time', '$objectID')");

}


if($action == 'delete'){
  mysql_query("TRUNCATE TABLE `GpsData`");
}

mysql_close();
?>
