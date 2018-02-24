exec dbms_java.grant_permission( 'ESQUEMA', 'SYS:java.net.SocketPermission', '192.168.1.36:8080', 'connect,resolve' );
commit;
