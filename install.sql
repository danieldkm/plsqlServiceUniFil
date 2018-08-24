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

@@src/o_canvas.type.decl.sql
@@src/o_canvas.type.impl.sql
@@src/o_canvas_usuario.type.decl.sql
@@src/o_canvas_usuario.type.impl.sql
@@src/o_canvas_periodo_academico.type.decl.sql
@@src/o_canvas_periodo_academico.type.impl.sql
@@src/o_canvas_curso.type.decl.sql
@@src/o_canvas_curso.type.impl.sql
@@src/o_canvas_secao.type.decl.sql
@@src/o_canvas_secao.type.impl.sql
@@src/o_canvas_inscricao.type.decl.sql
@@src/o_canvas_inscricao.type.impl.sql
