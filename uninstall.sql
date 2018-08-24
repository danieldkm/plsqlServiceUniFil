--Uninstall
begin
  /* drop old install */
  begin execute immediate 'drop type o_canvas_cursos'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_usuarios'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_periodos_academicos'; exception when others then null; end;
  begin execute immediate 'drop type o_canvas_secoes'; exception when others then null; end;
end;