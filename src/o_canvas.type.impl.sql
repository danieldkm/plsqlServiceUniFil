set define off
/*
    Copyright (c) 2018 Daniel Keyti Morita

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/
create or replace type body o_canvas is

    /* Construtores */
    constructor function o_canvas return self as result is
    begin
        self.script    := '/home/oracle/integracaoCanvas';
        self.show_log  := 'true';

        self.variables := new pljson;
        self.variables.put('script', self.script);
        self.variables.put('show_log', self.show_log);
        return;
    end;

    constructor function o_canvas(pnm_entidade varchar2) return self as result is
    begin
        self.entidade  := pnm_entidade;
        self.script    := '/home/oracle/integracaoCanvas';
        self.show_log  := 'true';
        self.variables := new pljson;
        self.variables.put('entidade', self.entidade);
        self.variables.put('script', self.script);
        self.variables.put('show_log', self.show_log);
        return;
    end;
    
    /* GETs and SETs */
    member procedure set_entidade (p_entidade varchar2) is begin self.entidade  := p_entidade;  end;
    member procedure set_script   (p_script   varchar2) is begin self.script    := p_script;    end;
    member procedure set_metodo   (p_metodo   varchar2) is begin self.metodo    := p_metodo;    end;
    member procedure set_acao     (p_acao     varchar2) is begin self.acao      := p_acao;      end;
    member procedure set_show_log (p_show_log varchar2) is begin self.show_log  := p_show_log;  end;
    member procedure set_variables(p_variables pljson)  is begin self.variables := p_variables; end;

    member function get_entidade return varchar2 is begin return self.entidade; end;
    member function get_script(SELF IN OUT NOCOPY o_canvas)   return varchar2 is 
    begin 
        if self.script is null then
            self.script := '/home/oracle/integracaoCanvas';
            return self.script;
        else
            return self.script;
        end if;
    end;
    member function get_metodo   return varchar2 is begin return self.metodo;   end;
    member function get_acao     return varchar2 is begin return self.acao;     end;
    member function get_show_log return boolean is 
    begin 
        if upper(self.show_log) = 'true' then 
            return true;
        else
            return false;
        end if;
    end;
    member function get_variables return pljson is begin return self.variables; end;

    member procedure set_default(SELF IN OUT NOCOPY o_canvas) is
        v_pljson pljson;
    begin
        v_pljson := self.get_variables;
        if v_pljson.exist('entidade') then
            self.set_entidade(v_pljson.get('entidade').get_string);
        end if;

        if v_pljson.exist('script') then
            self.set_script(v_pljson.get('script').get_string);
        end if;

        if v_pljson.exist('metodo') then
            self.set_metodo(v_pljson.get('metodo').get_string);
        end if;

        if v_pljson.exist('acao') then
            self.set_acao(v_pljson.get('acao').get_string);
        end if;
    end;

    /* CRUD */
    member function inserir_em_lote(SELF IN OUT NOCOPY o_canvas, p_json clob, r_msg out clob) return pljson is
        retorno pljson;
    begin 
        self.set_acao('POST'); 
        self.set_metodo(self.get_metodo || '/create');
        if p_json is not null then
            retorno := self.call_request(p_json, 'Inserir: '|| self.get_entidade ||'''s', r_msg);
            self.set_default;
            return retorno;
        else
            self.set_default; 
            r_msg := '{"error": "p_json não pode ser nulo"}';
            return null;
        end if;
    exception
        when others then
            self.set_default;
            r_msg := 'o_canvas.inserir_em_lote' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    member function inserir (SELF IN OUT NOCOPY o_canvas, p_json varchar2, r_msg out clob) return pljson is
        retorno pljson;
    begin 
        self.set_acao('POST');
        if p_json is not null then
            retorno := self.call_request(p_json, 'Inserir: ' || self.get_entidade , r_msg);
            self.set_default;
            return retorno;
        else 
            self.set_default;
            r_msg := '{"error": "p_json não pode ser nulo"}';
            return null;
        end if;
    exception
        when others then
            self.set_default;
            r_msg := 'o_canvas.inserir: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    member function atualizar (SELF IN OUT NOCOPY o_canvas, p_id varchar2, p_json varchar2, r_msg out clob) return pljson is
        retorno pljson;
    begin 
        self.set_acao('PUT');
        if p_id is not null then
            self.set_metodo(self.get_metodo||p_id);
        else 
            self.set_default;
            r_msg := '{"error": "p_id não pode ser nulo"}';
            return null;
        end if;
        
        if p_json is not null then
            retorno := self.call_request(p_json, 'Atualizar: ' || self.get_entidade , r_msg);
            self.set_default;
            return retorno;
        else
            self.set_default;
            r_msg := '{"error": "p_json não pode ser nulo"}';
            return null;
        end if;
    exception
        when others then
            self.set_default;
            r_msg := 'o_canvas.atualizar: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    member function deletar  (SELF IN OUT NOCOPY o_canvas, p_id varchar2, r_msg out clob) return pljson is
        retorno pljson;
    begin 
        self.set_acao('DELETE');
        if p_id is not null then
            self.set_metodo(self.get_metodo || p_id);
            retorno := self.call_request(null, 'Deletar: ' || self.get_entidade, r_msg);
            self.set_default;
            return  retorno;
        else
            self.set_default;
            r_msg := '{"error": "p_id não pode ser nulo"}';
            return null;
        end if;
    exception
        when others then
            self.set_default;
            r_msg := 'o_canvas.deletar: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    /* Requisições */
    member procedure execute_hostcommand(SELF IN OUT NOCOPY o_canvas,p_action in varchar2, p_method in varchar2, p_json in clob default null, r_json out clob, r_msg out clob) is
        l_output  dbms_output.chararr;
        l_lines   integer := 1000000;
        l_tmp_lob clob;
            
        function eliminar_sujeira(t clob) return clob is
        begin
            --dbms_output.put_line('t==='||t);
            if t like 'Process out%' 
--            and t not like '%Erro%' 
            and t not like '%Sintaxe%'
            and t not like '%informado deve ser GET ou POSTthen%' 
            and t not like '%Runtime Error%' then
                return replace(t, 'Process out :', '');
            end if;
            return empty_clob();
        end;
        
        
    begin
        dbms_output.disable;
        dbms_output.enable(1000000);
        dbms_java.set_output(1000000);
        --host_command3('/home/oracle/integracaoCanvas,GET,users?page1');
        if p_json is null then
            host_command3(self.get_script||','||p_action||','||p_method);
        else--TRANSLATE (col_name, 'x'||CHR(10)||CHR(13), 'x')
            host_command3(self.get_script||','||p_action||','||p_method||',<json>'||replace(TRANSLATE(p_json,  'x'||chr(10)||chr(13), 'x'), 'null', '""')||'</json>');--p_json TODO
        end if;
        dbms_output.get_lines(l_output, l_lines);
        for i in 1 .. l_lines loop
            l_tmp_lob := eliminar_sujeira(l_output(i));
            --util.p(l_output(i));
--            if g_is_debug then
--                dbms_output.put_line(UNISTR(l_output(i)));
--            end if;
            r_msg := r_msg || chr(10) ||l_output(i);
            if (l_tmp_lob != empty_clob()) then
                r_json := r_json || l_tmp_lob;
            end if;
        end loop;
    end execute_hostcommand;

    member function call_request(SELF IN OUT NOCOPY o_canvas, p_json varchar2, p_ds_chamada varchar2, r_msg out clob) return pljson is
        w_log       clob;
        w_msg       clob;
        w_resposta  clob;
    begin
        --w_log      := 'Inicio: '||p_ds_chamada;
        --w_log      := w_log || chr(10) || 'Entidade: ' || self.get_entidade;
        self.request(p_json, self.get_acao, '/' || self.get_entidade || self.get_metodo, p_ds_chamada, w_resposta, w_msg);
        
        w_log := w_log || chr(10) || w_msg;
        
        if self.get_show_log then
            util.plob(w_log, p_debug => true);
        end if;
        
        r_msg := w_log;
        if w_resposta is not null and w_resposta like '{%' then
            return pljson(w_resposta);
        else
            return null;
        end if;
    end;

    member procedure request_get(SELF IN OUT NOCOPY o_canvas, p_metodo varchar2, p_ds_chamada varchar2, r_json out clob, r_log out clob) is
        w_msg clob;
    begin
        r_log         := 'Inicio: ' || p_ds_chamada;
        r_log         := r_log || chr(10) || 'Entidade: '   || self.get_entidade;
        r_log         := r_log || chr(10) || 'Requisição: ' || p_metodo;

        self.execute_hostcommand(p_action => 'GET'     --Tipo
                                ,p_method => p_metodo  --Chamada
                                ,r_json   => r_json    --Resposta
                                ,r_msg    => w_msg     --Log
                                );
                                  
        r_log := r_log || chr(10) || w_msg;
        r_log := r_log || chr(10) || 'Resposta: ' || r_json;
        r_log := r_log || chr(10) || '-----------------------------------------------------------------------------------------------'||chr(10);
        exception
            when others then
                r_log := r_log || chr(10) || util.get_erro;
    end;
    
    member procedure request(SELF IN OUT NOCOPY o_canvas, p_json varchar2, p_action varchar2, p_metodo varchar2, p_ds_chamada varchar2, r_json out clob, r_log out clob) is
        w_msg clob;
    begin
        r_log         := 'Inicio: ' || p_ds_chamada;
        r_log         := r_log || chr(10) || 'Entidade: '   || self.get_entidade;
        r_log         := r_log || chr(10) || 'Requisição: ' || p_metodo;

        self.execute_hostcommand(p_action => p_action  --Tipo
                                ,p_method => p_metodo  --Chamada
                                ,p_json   => p_json    --JSON
                                ,r_json   => r_json    --Resposta
                                ,r_msg    => w_msg     --Log
                                );
                                  
        r_log := r_log || chr(10) || w_msg;
        r_log := r_log || chr(10) || 'Resposta: ' || r_json;
        r_log := r_log || chr(10) || '-----------------------------------------------------------------------------------------------'||chr(10);
        
        exception
            when others then
                r_log := r_log || chr(10) || util.get_erro;
    end;

    /* Buscas */
    
    member function find_by_method(SELF IN OUT NOCOPY o_canvas, p_metodo varchar2, p_ds_chamada varchar2, has_pagination boolean default false, r_msg out clob) return pljson_list is
    
        w_json        clob;
        w_msg         clob;
        w_log         clob;
        w_pljson_list pljson_list;
        v_pagina      binary_integer;
        w_paginacao   varchar2(1000);
        w_metodo      varchar2(1000);
    begin
        
        if has_pagination then
            w_paginacao   := '?page=<page>&per_page=50&state%5B%5D=active&state%5B%5D=inactive&state%5B%5D=invited&state%5B%5D=deleted&state%5B%5D=creation_pending&state%5B%5D=rejected&state%5B%5D=complet';
            v_pagina      := 0;
            
            loop
                v_pagina := v_pagina + 1;
                w_metodo := self.get_entidade || p_metodo || replace(w_paginacao, '<page>', v_pagina);
                w_log := w_log || chr(10) || 'Página: '     || v_pagina;
                self.request_get(p_metodo, p_ds_chamada, w_json, w_msg);
                w_log := w_log || chr(10) || w_msg;
                
                exit when w_json is null or w_json = '' or w_json = '[]' or w_json = '{}';
                
                if w_pljson_list is null then
                    w_pljson_list := new pljson_list(w_json);
                else
                    w_pljson_list := pljson_helper.join(w_pljson_list, new pljson_list(w_json));
                end if;
                w_json   := null;
                
            end loop;
            
        else 
        
            self.request_get(self.get_entidade || p_metodo, p_ds_chamada, w_json, w_log);
            if w_json like '{%' then
                w_pljson_list := new pljson_list('[' || w_json || ']');
            elsif w_json like '[%' then
                w_pljson_list := new pljson_list(w_json);
            end if;
            
        end if;
        
        if w_pljson_list is not null and self.get_show_log then
            w_log := w_log || chr(10) || 'PLJSON_LIST: ' || w_pljson_list.to_char;
        end if;
        if self.get_show_log then
            util.plob(w_log, p_debug => true);
        end if;
        r_msg := w_log;
        self.set_default;
        return w_pljson_list;
        exception
            when others then
                w_log := w_log || chr(10) || 'Error: ' || util.get_erro;
                if self.get_show_log then
                    util.plob(w_log, p_debug => true);
                end if;
                r_msg := w_log;
                return w_pljson_list;
    end;

    member function find_all(SELF IN OUT NOCOPY o_canvas, r_msg out clob) return pljson_list is
        w_json        clob;
        w_msg         clob;
        w_log         clob;
        w_metodo      varchar2(1000);
        w_paginacao   varchar2(1000);
        v_pagina      binary_integer;
        w_pljson_list pljson_list;
        
    begin
        
        w_paginacao   := 'page=<page>&per_page=50&state%5B%5D=active&state%5B%5D=inactive&state%5B%5D=invited&state%5B%5D=deleted&state%5B%5D=creation_pending&state%5B%5D=rejected&state%5B%5D=complet';
        --w_pljson_list := new pljson_list('[]');
        v_pagina      := 0;
        w_log         := 'Inicio: find_all';
        w_log         := w_log || chr(10) || 'Entidade: ' || self.get_entidade;

        if self.get_metodo is not null then
            w_paginacao := self.get_metodo || '&' || w_paginacao;
        else
            w_paginacao := '?' || w_paginacao;
        end if;

        loop

            v_pagina := v_pagina + 1;

            w_metodo := self.entidade || replace(w_paginacao, '<page>', v_pagina);
            
            w_log := w_log || chr(10) || 'Requisição: ' || w_metodo;
            w_log := w_log || chr(10) || 'Página: '     || v_pagina;

            self.execute_hostcommand(p_action => 'GET' --Tipo
                                      ,p_method => w_metodo  --Chamada
                                      ,r_json   => w_json    --Resposta
                                      ,r_msg    => w_msg     --Log
                                      );
            w_log := w_log || chr(10) || w_msg;
            w_log := w_log || chr(10) || 'Resposta: '     || substr(w_json, 1, 32000);
            w_log := w_log || chr(10) || '-----------------------------------------------------------------------------------------------'||chr(10);
            
            exit when w_json is null or w_json = '' or w_json = '[]' or w_json = '{}';
            if w_pljson_list is null then
                w_pljson_list := new pljson_list(w_json);
            else
                w_pljson_list := pljson_helper.join(w_pljson_list, new pljson_list(w_json));
            end if;
            w_json   := null;
        end loop;
    
        w_log := w_log || chr(10) || 'Retorno: ' || w_pljson_list.to_char;
        if self.get_show_log then
            util.plob(w_log, p_debug => true);
        end if;
        self.set_default;
        return w_pljson_list;
        exception
            when others then
                self.set_default;
                w_log := w_log || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(w_log, p_debug => true);
                end if;
                return w_pljson_list;
    end;

    member function find_by_id(SELF IN OUT NOCOPY o_canvas, p_id varchar2, r_msg out clob) return pljson is
        w_json        clob;
        w_msg         clob;
        w_log         clob;
        w_metodo      varchar2(1000);
        w_pljson      pljson;
    begin
        w_log         := 'Inicio: find_by_id ('||p_id||')';
        w_log         := w_log || chr(10) || 'Entidade: ' || self.get_entidade;
        w_log         := w_log || chr(10) || 'Script: ' || self.get_script;
        
        w_metodo := self.get_entidade || self.get_metodo || p_id;
        
        w_log := w_log || chr(10) || 'Requisição: ' || w_metodo;

        self.execute_hostcommand(p_action => 'GET'     --Tipo
                                ,p_method => w_metodo  --Chamada
                                ,r_json   => w_json    --Resposta
                                ,r_msg    => w_msg     --Log
                                );
                                  
        w_log := w_log || chr(10) || w_msg;
        w_log := w_log || chr(10) || 'Resposta: '     || substr(w_json, 1, 32000);
        w_log := w_log || chr(10) || '-----------------------------------------------------------------------------------------------'||chr(10);

        if w_json is not null or w_json != '{}' or w_json != '' or w_json != '[]' then
            w_pljson := new pljson(w_json);
        end if;
    
        w_log := w_log || chr(10) || 'Retorno: ' || w_pljson.to_char;
        if self.get_show_log then
            util.plob(w_log, p_debug => true);
        end if;
        self.set_default;
        return w_pljson;
        exception
            when others then
                self.set_default;
                w_log := w_log || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(w_log, p_debug => true);
                end if;
                return w_pljson;   
    end;

    /* Controles */

    member function controller_prepare_json(p_pljson pljson, p_entity in varchar2, p_template varchar2, validate_json boolean, r_msg out clob) return varchar2 is
        tmp_json pljson;
        w_str_json clob;
    begin
        if p_entity is not null then
            r_msg := r_msg || chr(10) || 'Remover atributos vazios';
            tmp_json := canvas.util_remove_empty_column(p_pljson);
            w_str_json := '{"'||upper(p_entity)||'":'||tmp_json.to_char(false)||'}';
        else
            r_msg := r_msg || chr(10) || 'Remover atributos vazios';
            tmp_json := canvas.util_remove_empty_column(p_pljson);
            w_str_json := tmp_json.to_char(false);
        end if;
        if validate_json then
            r_msg := r_msg || chr(10) || 'Validar a estrutura do json com base no template';
            if not(canvas.util_validate_json(p_template, upper(w_str_json))) then
                raise canvas.e_formato_json_invalido;
            end if;
        end if;
        return w_str_json;
        exception
            when canvas.e_formato_json_invalido then
                r_msg := r_msg || chr(10) || 'Inicio Erro;';
                r_msg := r_msg || chr(10) || replace(canvas.msg_e_formato_json_invalido, 'dado', coalesce(w_str_json, ''));
                r_msg := r_msg || chr(10) || 'Fim Erro';
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro;';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
    end;
    
    member procedure controller_save_request(p_sql in varchar2, p_method in varchar2, p_ds_entity in varchar2, p_entity in varchar2, p_nm_table in varchar2, p_template in varchar2, is_batch in boolean, p_verify_id in boolean,r_msg out clob, p_method_find varchar2 default '?&search_term=', is_update boolean default true) is
    
        w_nm_primary_key varchar2(100);
        w_id             varchar2(100);
        w_qt_inserido    integer;
        w_qt_atualizado  integer := 0;
        w_str_json       clob;
        w_msg            clob;  
        w_json_list      pljson_list;    
        w_o_json         pljson;
        w_lista_json     clob;
        
        procedure log_footer is
        begin
            if w_qt_atualizado > 0 then
                r_msg := r_msg || chr(10) || 'Atualizado: '||to_char(w_qt_atualizado);
            end if;
            r_msg := r_msg || chr(10) || 'Inserido: '||to_char(w_qt_inserido);
            r_msg := r_msg || chr(10) || 'Fim do metodo insert: '||p_ds_entity||'(s)';
        end;
        
    begin
        
        w_qt_inserido := 0;
        if instr(upper(p_entity), 'COURSE_SECTION') > 0 or instr(upper(p_entity), 'ENROLLMENT') > 0 then 
            w_nm_primary_key := 'SIS_SECTION_ID';
        else
            w_nm_primary_key := 'SIS_'||upper(p_entity)||'_ID';
        end if;
        if self.get_show_log then util.p(p_sql); end if;
        r_msg := 'Inicio do método insert: '||p_method;
        r_msg := r_msg || chr(10) || 'Inserir:' || p_ds_entity;
        if upper(p_sql) like '%"'||upper(p_entity)||'"%' or upper(p_entity) = 'GROUP' then
            if is_batch then
                r_msg := r_msg || chr(10) || 'Converter StringJson em PLJSON';
                w_json_list := pljson_list(p_sql);
                r_msg := r_msg || chr(10) || 'Iniciar requisição em lote';
                w_str_json := controller_prepare_json(pljson(w_json_list.get(1)), p_entity, p_template, true, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Chamada do serviço (service_save_request)';
               --TODO service_save_request(w_str_json, p_entity, p_nm_table, p_method, p_template, is_batch, w_msg, is_update);
                
            else
                r_msg := r_msg || chr(10) || p_sql;
                r_msg := r_msg || chr(10) || 'Requisição individual';
                w_str_json := controller_prepare_json(pljson(p_sql), null, p_template, true, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Chamada do serviço (service_save_request)';
          --TODO      service_save_request(w_str_json, null, p_nm_table, p_method, p_template, is_batch, w_msg, is_update);
                r_msg := r_msg || chr(10) || w_msg;
            end if;
        else
            
            r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
            w_json_list := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
            r_msg := r_msg || chr(10) || 'Quantidade a ser inserido: '||w_json_list.count;
            r_msg := r_msg || chr(10) || 'Iniciar requisição em lote';
--            if is_batch then
--                raise e_batch_not_found;
--            end if;
            for i in 1..w_json_list.count loop
--                declare
--                    tmp_json pljson;
                begin
--                    tmp_json := util_remove_empty_column(json(w_json_list.get(i)));
--                    w_str_json := '{"'||upper(p_entity)||'":'||tmp_json.to_char(false)||'}';
--                    w_str_json := replace(w_str_json, 'null', '""');
                    r_msg := r_msg || chr(10) || '-----------------------------------------------------------------------------';
                    w_str_json := controller_prepare_json(pljson(w_json_list.get(i)), p_entity, p_template, true, w_msg);
                    r_msg := r_msg || chr(10) || w_msg;
                    /*TODOif not(service_is_exist_id(w_str_json, p_method_find, w_nm_primary_key, p_entity, p_nm_table, p_verify_id, w_msg)) then
                        r_msg := r_msg || chr(10) || w_msg;
--                        if not(util_validate_json(p_template, w_str_json)) and i = 1 then
--                            r_msg := r_msg || chr(10) || w_str_json;
--                            raise e_formato_json_invalido;
--                        else
                            if is_batch then
                                if  w_json_list.count = i then
                                    w_lista_json := w_lista_json ||','||w_str_json||']';
                                elsif w_lista_json is not null then
                                    w_lista_json := w_lista_json|| ','||w_str_json;
                                else
--                                    extract_info;
--                                    get_key_when_batch;
                                    w_lista_json := '['||w_str_json;
                                end if;
                            else
                                service_save_request(w_str_json, p_entity, p_nm_table, p_method, p_template, is_batch, w_msg, is_update);
--                                extract_info;
--                                service_save_request(w_str_json, w_function, w_key, w_update, p_nm_table, is_batch, w_msg);
                                r_msg := r_msg || chr(10) || w_msg;
                                if r_msg not like '%erro%' then
                                    w_qt_inserido := (w_qt_inserido + 1);
                                end if;
                            end if;
--                        end if;
                        
                    else
                        r_msg := r_msg || chr(10) || w_msg;
                        w_qt_atualizado := w_qt_atualizado + 1;
                    end if;*/
                    
                exception
                    when canvas.e_table_not_update then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || replace(canvas.msg_e_table_not_update, 'dado', 'Não atualizou ('||p_nm_table||')');
                    when canvas.e_formato_json_invalido then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || replace(canvas.msg_e_formato_json_invalido, 'dado', 'Template:'||p_template||chr(10)||w_str_json);
                    when others then
                        r_msg := r_msg || chr(10) || w_msg;
                        r_msg := r_msg || chr(10) || 'Inicio Erro:';
                        r_msg := r_msg || chr(10) || util.get_erro;
                        r_msg := r_msg || chr(10) || 'Fim Erro';
                end;
            end loop;
            if is_batch then
--                util.p('w_lista_json:'||w_lista_json);
--                util.p('w_function:'||w_function);
--                util.p('w_key:'||w_key);
--                util.p('w_update:'||w_update);
--                service_save_request(w_lista_json, w_function, w_key, w_update, p_nm_table, is_batch, w_msg);
                --TODO service_save_request(w_lista_json, p_entity, p_nm_table, p_method, p_template, is_batch, w_msg);
                r_msg := r_msg || chr(10) || w_msg;
            end if;
        end if;
            log_footer;
        exception
            when canvas.e_formato_json_invalido then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || replace(canvas.msg_e_formato_json_invalido, 'dado', '');
                log_footer;
            when canvas.e_batch_not_found then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || canvas.msg_e_batch_not_found;
                log_footer;
            when others then
                r_msg := r_msg || chr(10) || w_msg;
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
                log_footer;
    end controller_save_request;
end;
/
sho err