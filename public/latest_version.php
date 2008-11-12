<?php

$handle = mysql_connect("localhost", "cmsforgeuser", "usercmsforge");
mysql_select_db('cmsforge_production', $handle);
$query = "select name from releases where package_id = 1 order by created_at desc limit 1";
$result = mysql_query($query, $handle);
if (mysql_num_rows($result) > 0)
{
        while ($row = mysql_fetch_assoc($result))
        {
                echo "cmsmadesimple:" . $row['name'];
		break;
        }
        mysql_free_result($result);
        unset($result);
}

mysql_close($handle);

?>
