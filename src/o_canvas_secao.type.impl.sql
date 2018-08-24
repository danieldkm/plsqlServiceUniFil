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
create or replace type body o_canvas_secao is

    /* Construtores */
    constructor function o_canvas_secao return self as result is
    begin
        self.set_default_attribute;
        return;
    end;

    /* Gets and sets */
    member procedure set_default_attribute(SELF IN OUT NOCOPY o_canvas_secao) is
    begin
        self.set_entidade('sections');
        self.set_metodo('/sis_section_id:');
    end;
    
    /* Requisições */
    member function inserir (SELF IN OUT NOCOPY o_canvas_secao, p_sis_course_id varchar2, p_json varchar2, r_msg out clob) return pljson is
        retorno pljson;
    begin 
        self.set_acao('POST'); 
        if p_sis_course_id is null or p_json is null then
            r_msg := '{"error" : "p_sis_course_id/p_json não pode ser nulo"}';
            return null;
        end if;
        self.set_entidade('courses');
        self.set_metodo(self.get_metodo||p_sis_course_id||'/sections');
        retorno := self.call_request(p_json, 'Inserir secao', r_msg);
        self.set_default;
        return retorno;
    exception
        when others then
            self.set_default;
            r_msg := 'o_canvas_secao.inserir: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;
  
    member function deletar (SELF IN OUT NOCOPY o_canvas_secao, p_sis_section_id varchar2, p_group_id number default null, r_msg out clob) return pljson is
        retorno pljson;
    begin
        self.set_acao('DELETE');
        if p_group_id is not null then
            self.set_metodo(self.get_metodo || p_sis_section_id);
        else
            self.set_metodo(self.get_metodo || p_sis_section_id || '?group_id=' || to_char(p_group_id));
        end if;
        retorno := self.call_request(null, 'Deletar secao', r_msg);
        self.set_default;
        return retorno;
    exception
        when others then
            self.set_default;
            r_msg := 'o_canvas_secao.deletar: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;
    
    member function liberar_eliminar(SELF IN OUT NOCOPY o_canvas_secao, p_sis_section_id varchar2, r_msg out clob) return pljson is
        retorno pljson;
    begin
        self.set_acao('DELETE');
        if p_sis_section_id is null then
            r_msg := '{"error" : "p_sis_section_id não pode ser nulo"}';
            return null;
        end if;

        self.set_metodo(self.get_metodo||p_sis_section_id||'/release');
        retorno := self.call_request(null, 'Liberar e eliminar um curso', r_msg);
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := 'o_canvas_secao.liberar_eliminar: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
                return null;
    end;

    member function find_by_id(SELF IN OUT NOCOPY o_canvas_secao, p_sis_section_id varchar2, p_include varchar2 default null, r_msg out clob) return pljson_list is
    begin
        self.set_acao('GET');

        if p_sis_section_id is null then
            r_msg := '{"error" : "p_sis_section_id não pode ser nulo"}';
            return null;
        end if;

        if p_include is not null and lower(p_include) in ('active', 'invited') then
            self.set_metodo(self.get_metodo||p_sis_section_id||'?include='||p_include);
            return self.find_by_method(self.get_metodo, 'Obter detalhes de uma Seção', false, r_msg);
        end if;

        self.set_metodo(self.get_metodo||p_sis_section_id);
        return self.find_by_method(self.get_metodo, 'Obter detalhes de uma Seção', false, r_msg);
        exception
            when others then
                r_msg := 'o_canvas_secao.find_by_id: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
                return null;
    end;
end;
/
sho err