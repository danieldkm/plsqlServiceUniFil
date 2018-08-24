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
create or replace type body o_canvas_usuario is

    /* Construtores */
    constructor function o_canvas_usuario return self as result is
    begin
        self.set_default_attribute;
        return;
    end;

    /* Gets and sets */
    member procedure set_default_attribute(SELF IN OUT NOCOPY o_canvas_usuario) is
    begin
        self.set_entidade('users');
        self.set_metodo('/sis_user_id:');
    end;

    /*member function inserir_usuarios(SELF IN OUT NOCOPY o_canvas_usuario, p_json clob, r_msg out clob) return pljson is
    begin 
        self.set_acao('POST'); 
        self.set_metodo(self.get_metodo || '/create');
        return self.call_request(p_json, 'Inserir usuarios', r_msg);
    exception
        when others then
            r_msg := 'o_canvas_usuario.inserir_usuarios' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    member function inserir         (SELF IN OUT NOCOPY o_canvas_usuario, p_json varchar2, r_msg out clob) return pljson is begin self.set_acao('POST'); return self.call_request(p_json, 'Inserir curso'  , r_msg); end;

    member function atualizar (SELF IN OUT NOCOPY o_canvas_usuario, p_user_id varchar2, p_json varchar2, r_msg out clob) return pljson is 
    begin 
        self.set_acao('PUT');
        if p_user_id is not null then
            self.set_metodo(self.get_metodo||p_user_id);
        else 
            r_msg := '{"error": "p_user_id não pode ser nulo"}';
            return '{"error": "p_user_id não pode ser nulo"}';
        end if;
        return self.call_request(p_json, 'Atualizar Usuário' , r_msg);
    exception
        when others then
            r_msg := 'o_canvas_usuario.atualizar' || CHR(10) || 'Error:' || util.get_erro;
            return '{"error": '||util.get_erro||'}';
    end;*/

    member function unir(SELF IN OUT NOCOPY o_canvas_usuario, p_from_user_id varchar2, p_to_user_id varchar2, r_msg out clob) return pljson is
        w_log       clob;
        w_msg       clob;
        w_resposta  pljson;

        w_metodo   varchar2(1000);
    begin
        self.set_acao('PUT');
        self.set_metodo('/'||self.get_entidade || '/' || p_from_user_id || '/merge_into/' || p_to_user_id);
        --self.call_request(null, 'PUT', '/'||self.get_entidade || '/' || p_from_user_id || '/merge_into/' || p_to_user_id, 'Unir um usuário com outro', w_resposta, w_msg);
        w_resposta := self.call_request(null, 'Unir um usuário com outro', r_msg);

        w_log := w_log || chr(10) || w_msg;
        if self.get_show_log then
            util.plob(w_log, p_debug => true);
        end if;

        r_msg := w_log;
        return w_resposta;
    end;

    member function find_progress_by_id(SELF IN OUT NOCOPY o_canvas_usuario, user_id varchar2, p_sis_user_id varchar2, r_msg out clob) return pljson_list is
        w_log            clob;
        w_metodo         varchar2(1000);
        w_parametros     varchar2(1000);
        w_metodo_listar  varchar2(100) := '/progress';

    begin
        self.set_acao('GET');
        if user_id is null or p_sis_user_id is null then
            return null;
        else 
            w_parametros := user_id || '/progress?sis_course_id=' || p_sis_user_id;
            w_metodo := self.entidade || w_parametros;
            return self.find_by_method(w_metodo, 'find_progress_by_id', r_msg => r_msg);
        end if;
        exception
            when others then
                w_log := w_log || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(w_log, p_debug => true);
                end if;
                return null;
    end;

    member function find_all(SELF IN OUT NOCOPY o_canvas_usuario, p_account_id number default null, p_search_term varchar2 default null, r_log out clob) return pljson_list is
        w_parametros  varchar2(1000);
        w_param_1     varchar2(100) := 'account_id=';
        w_param_2     varchar2(100) := 'search_term=';
    begin
        self.set_acao('GET');
        if p_account_id is not null then
            w_parametros   := '?' || w_param_1 || p_account_id;
        end if;
        
        if p_search_term is not null then
            if w_parametros like '%?%' then
                w_parametros   := w_parametros || '&' || w_param_2 || p_search_term;
            else
                w_parametros   := w_parametros || '?' || w_param_2 || p_search_term;
            end if;
        end if;

        if w_parametros is not null then
            self.set_metodo(w_parametros);
            return self.find_all(r_log);
        else   
            self.set_metodo(null);
            return self.find_by_method(self.get_metodo, 'Find all usarios', false, r_log);
        end if;
        
    end;
end;
/
sho err