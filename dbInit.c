//  dbInit.c
//  David Buckingham

//**************************************************************************************************
// Creates database unless it already exists.
// Creates tables unless thye already exist.
// -overwrite argument deletes and replaces existing database
//**************************************************************************************************/

#include <my_global.h>
#include <mysql.h>
#include <errmsg.h>
#include <string.h>

MYSQL *conn;
void make_query(char* query) {
    if (mysql_query(conn, query)) {
        fprintf(stderr, "SQL Error: %d, %s\n", mysql_errno(conn), mysql_error(conn));
        fprintf(stderr, "Query: %s\n", query);
        exit(1);
    }
}

int main(int argc, char *argv[]) {
    conn = mysql_init(NULL);
    if ((conn == NULL) || (mysql_real_connect(conn, "localhost", "root", "", "", 0, NULL, 0) == NULL)) {
        printf("Error %u: %s\n", mysql_errno(conn), mysql_error(conn));
        return 1;
    }
    if ((argc == 2) && (!strcmp(argv[1], "-overwrite"))) {
        make_query("DROP DATABASE IF EXISTS snowcloud");
    }
    make_query("CREATE DATABASE IF NOT EXISTS snowcloud");
    make_query("USE snowcloud");
    make_query("CREATE TABLE IF NOT EXISTS SNOWDATA(myindex int unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY, \
							       mote INT NOT NULL, \
                                                               chanel INT NOT NULL, \
                                                               data INT NOT NULL, \
                                                               epoch INT, \
							       transmitted TINYINT(1) NOT NULL, \
                                                               INDEX (transmitted))");
    make_query("CREATE TABLE IF NOT EXISTS EPOCH_TIMES(myindex int unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY, \
                                                              mote INT NOT NULL, \
                                                              epoch INT NOT NULL, \
                                                              timestamp INT NOT NULL)");
    exit(0);
}
