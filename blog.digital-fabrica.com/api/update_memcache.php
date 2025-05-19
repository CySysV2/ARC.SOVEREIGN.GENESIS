<?php
$mem = new Memcached();
$mem->addServer("127.0.0.1", 11249);
$mem->set("latest_cid", "QmCID_FROM_ORCHESTRATION"); // <-- Replace with actual CID
$mem->set("epoch_status", "ΣΩΩ.5.0::Live");
$mem->set("last_sync_time", gmdate("Y-m-d\TH:i:s\Z"));
echo "Memcached updated.";
?> 