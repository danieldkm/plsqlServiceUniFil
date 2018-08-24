--Uninstall
begin
  /* drop old install */
  begin execute immediate 'drop type o_canvas_cursos'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_usuarios'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_periodos_academicos'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_secoes'; exception when others then null; end;
  /* drop new install */
  begin execute immediate 'drop type o_canvas_curso'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_usuario'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_periodo_academico'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_secao'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_inscricao'; exception when others then null; end;
--  begin execute immediate 'drop package util'; exception when others then null; end;
--  begin execute immediate 'drop package canvas'; exception when others then null; end;
end;