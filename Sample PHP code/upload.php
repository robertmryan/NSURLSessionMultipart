<?php
    
    $headers = array_change_key_case(getallheaders());
    
    //------------------------------------------------------
    
    header("Content-Type: application/json");
    
    $response["success"] = false;
    if (isset($_FILES))   $response["files"]   = $_FILES;
    if (isset($_SERVER))  $response["server"]  = $_SERVER;
    if (isset($_SESSION)) $response["session"] = $_SESSION;
    if (isset($_REQUEST)) $response["request"] = $_REQUEST;
    if (isset($_POST))    $response["post"]    = $_POST;
    
    $allowedExts = array("jpg", "jpeg", "gif", "png");
    
    if (!isset($_FILES["file"]))
    {
        $response["error"] = "no file provided";
    }
    else
    {
        $filename = $_FILES["file"]["name"];
        $filename_components = explode(".", $filename);
        $extension = end($filename_components);
        if (in_array($extension, $allowedExts))
        {
            if ($_FILES["file"]["error"] > 0)
            {
                $response["error"] = $_FILES["file"]["error"];
            }
            else
            {
                if (file_exists("upload/" . $_FILES["file"]["name"]))
                {
                    $response["error"] = $_FILES["file"]["name"] . " already exists";
                }
                else
                {
                    move_uploaded_file($_FILES["file"]["tmp_name"], "upload/" . $_FILES["file"]["name"]);
                    $response["success"] = true;
                }
            }
        }
        else
        {
            $response["error"] = "Invalid file";
        }
    }
    
    echo json_encode($response);
    
    ?>
