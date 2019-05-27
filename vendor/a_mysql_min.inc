// NOTE: this is edited, see a_mysql.inc for the original

/*
 * MySQL plugin R39-3
 */


#if defined mysql_included
	#endinput
#endif
#define mysql_included


/*
 * Common error codes
 *
 * Client: http://dev.mysql.com/doc/refman/5.1/en/error-messages-client.html
 * Server: http://dev.mysql.com/doc/refman/5.1/en/error-messages-server.html
 */

#define ER_DBACCESS_DENIED_ERROR 		1044
#define ER_ACCESS_DENIED_ERROR 			1045
#define ER_UNKNOWN_TABLE 				1109
#define ER_SYNTAX_ERROR 				1149
#define CR_SERVER_GONE_ERROR 			2006
#define CR_SERVER_LOST 					2013
#define CR_COMMAND_OUT_OF_SYNC 			2014
#define CR_SERVER_LOST_EXTENDED 		2055

#define cache_get_field_str(%0,%1,%2) cache_get_row(%0,%1,%2)
#define cache_get_field_int(%0,%1,%2) %2=cache_get_row_int(%0,%1)
#define cache_get_field_flt(%0,%1,%2) %2=cache_get_row_float(%0,%1)
#define cache_get_field_int_nullable_default0_usebuf32(%0,%1,%2) cache_get_row(%0,%1,buf32);if(strcmp("NULL",buf32,false)==0){%2=0;}else{cache_get_field_int(%0,%1,%2);}

enum E_LOGLEVEL
{
	LOG_NONE = 0,
	LOG_ERROR = 1,
	LOG_WARNING = 2,
	LOG_DEBUG = 4,

	LOG_ALL = LOG_ERROR | LOG_WARNING | LOG_DEBUG
};

enum E_LOGTYPE
{
	LOG_TYPE_TEXT = 1,
	LOG_TYPE_HTML = 2
};

enum E_VAR_DATATYPE
{
	DATATYPE_INT,
	DATATYPE_FLOAT,
	DATATYPE_STRING
};

enum E_MYSQL_OPTION
{
	DUPLICATE_CONNECTIONS,
	LOG_TRUNCATE_DATA
};

enum E_EXECTIME_UNIT
{
	UNIT_MILLISECONDS,
	UNIT_MICROSECONDS
};


#define mysql_real_escape_string 					mysql_escape_string
#define cache_num_fields 							cache_get_field_count
#define cache_num_rows 								cache_get_row_count
#define mysql_reload(%0) 							mysql_tquery(%0,"FLUSH PRIVILEGES")
#define mysql_debug(%0)								(%0?mysql_log(LOG_ALL):mysql_log())
#define ismysqlnull(%0) 							(strcmp(%0,"NULL",false)==0)

// MySQL functions
native mysql_log(E_LOGLEVEL:loglevel = LOG_ERROR | LOG_WARNING, E_LOGTYPE:logtype = LOG_TYPE_TEXT);
native mysql_connect(const host[], const user[], const database[], const password[], port = 3306, bool:autoreconnect = true, pool_size = 2);
native mysql_close(connectionHandle = 1);
native mysql_reconnect(connectionHandle = 1);

native mysql_unprocessed_queries(connectionHandle = 1);
native mysql_current_handle();
native mysql_option(E_MYSQL_OPTION:type, value);

native mysql_errno(connectionHandle = 1);
native mysql_escape_string(const source[], destination[], connectionHandle = 1, max_len = sizeof(destination));
/// <remarks>
///   <b>Format Specifiers:</b><p/>
///   <ul>
///     <li><b><c>%%</c></b> - literal %</li>
///     <li><b><c>%i/%d</c></b> - integer</li>
///     <li><b><c>%u</c></b> - unsigned integer</li>
///     <li><b><c>%o</c></b> - octal number</li>
///     <li><b><c>%x/%X</c></b> - hexadecimal number (lowercase/uppercase)</li>
///     <li><b><c>%b</c></b> - binary number</li>
///     <li><b><c>%f</c></b> - floating-point number (will print <c><b>inf</b></c> and <c><b>nan</b></c>)</li>
///     <li><b><c>%a/%A</c></b> - hexadecimal floating-point number (lowercase/uppercase)</li>
///     <li><b><c>%g/%G</c></b> - floating-point number, scientific notation</li>
///     <li><b><c>%s</c></b> - string</li>
///     <li><b><c>%e</c></b> - escaped string</li>
///   </ul>
/// </remarks>
/// <returns><b><c>1</c></b> if the query was successfully queued</returns>
native mysql_format(connectionHandle, output[], len, format[], {Float,_}:...);
native mysql_pquery(connectionHandle, query[], callback[] = "", format[] = "", {Float,_}:...);
/// <remarks>
///   <b>Format Specifiers:</b><p/>
///   <ul>
///     <li><b><c>%i/%d</c></b> - integer (whole number)</li>
///     <li><b><c>%s</c></b> - string</li>
///     <li><b><c>%f</c></b> - floating-point number (Float: tag)</li>
///     <li><b><c>%b</c></b> - boolean</li>
///     <li><b><c>%r</c></b> - reference</li>
///     <li><b><c>%a</c></b> - array, has to be followed by d/i with array length as argument</li>
///   </ul>
/// </remarks>
/// <returns><b><c>1</c></b> if the query was successfully queued</returns>
/// <seealso name="mysql_format" />
native mysql_tquery(connectionHandle = 1, query[], callback[] = "", format[] = "", {Float,_}:...);
native Cache:mysql_query(conhandle, query[], bool:use_cache = true);

native mysql_stat(destination[], connectionHandle = 1, max_len = sizeof(destination));
native mysql_get_charset(destination[], connectionHandle = 1, max_len = sizeof(destination));
native mysql_set_charset(charset[], connectionHandle = 1);


// Cache functions
native cache_get_data(&num_rows, &num_fields, connectionHandle = 1);

/// <param name="connectionHandle">connection handle (optional=<b><c>1</c></b>)</param>
/// <returns>the row count</returns>
native cache_get_row_count(connectionHandle = 1);
native cache_get_field_count(connectionHandle = 1);
native cache_get_field_name(field_index, destination[], connectionHandle = 1, max_len = sizeof(destination));

/// <param name="connectionHandle">(optional=<b><c>1</c></b>)</param>
/// <param name="max_len">(optional=<b><c>sizeof destination</c></b>)</param>
native cache_get_row(row, field_idx, destination[], connectionHandle = 1, max_len = sizeof(destination));
native cache_get_row_int(row, field_idx, connectionHandle = 1);
native Float:cache_get_row_float(row, field_idx, connectionHandle = 1);

native cache_get_field_content(row, const field_name[], destination[], connectionHandle = 1, max_len = sizeof(destination));
native cache_get_field_content_int(row, const field_name[], connectionHandle = 1);
native Float:cache_get_field_content_float(row, const field_name[], connectionHandle = 1);

native Cache:cache_save(connectionHandle = 1);
native cache_delete(Cache:cache_id, connectionHandle = 1);
native cache_set_active(Cache:cache_id, connectionHandle = 1);
native cache_is_valid(Cache:cache_id, connectionHandle = 1);

native cache_affected_rows(connectionHandle = 1);
native cache_insert_id(connectionHandle = 1);
native cache_warning_count(connectionHandle = 1);

native cache_get_query_exec_time(E_EXECTIME_UNIT:unit = UNIT_MICROSECONDS);
native cache_get_query_string(destination[], max_len = sizeof(destination));


// Forward declarations
forward OnQueryError(errorid, error[], callback[], query[], connectionHandle);

