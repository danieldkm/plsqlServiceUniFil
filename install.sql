PROMPT -- Setting optimize level --

/*
11g
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 3;
ALTER SESSION SET plsql_code_type = 'NATIVE';
*/
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL = 2;

PROMPT -----------------------------------;
PROMPT -- Compiling objects for PL/JSON --;
PROMPT -----------------------------------;
@@uninstall.sql

@@src/o_canvas.sql
@@src/o_canvas_usuarios.sql
@@src/o_canvas_periodos_academicos.sql
@@src/o_canvas_cursos.sql
@@src/o_canvas_secoes.sql

