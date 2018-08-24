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
create or replace type body o_canvas_periodo_academico is

    /* Construtores */
    constructor function o_canvas_periodo_academico return self as result is
    begin
        self.set_entidade('terms');
        self.set_metodo('/sis_term_id:');
        return;
    end;

    /* Requisições */
    member function inserir   (SELF IN OUT NOCOPY o_canvas_periodo_academico, p_json varchar2, r_msg out clob) return pljson is 
    begin 
        self.set_acao('POST'); 
        return self.call_request(p_json, 'Inserir Periodo Academico'   , r_msg); 
    exception
        when others then
            r_msg := 'o_canvas_periodo_academico.inserir' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    member function atualizar (SELF IN OUT NOCOPY o_canvas_periodo_academico, p_json varchar2, p_old_sis_term_id varchar2 default null, r_msg out clob) return pljson is 
        w_json pljson;
    begin 
        self.set_acao('PUT');
        if p_old_sis_term_id is not null
            self.set_metodo(self.get_metodo||p_old_sis_term_id);
        else 
            w_json := new pljson(p_json);
        end if;
        return self.call_request(p_json, 'Atualizar Periodo Academico' , r_msg);
    exception
        when others then
            r_msg := 'o_canvas_periodo_academico.atualizar' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    member function deletar  (SELF IN OUT NOCOPY o_canvas_periodo_academico, p_sis_term_id varchar2, p_account_id number, r_msg out clob) return pljson is 
    begin 
        self.set_acao('DELETE');
        if p_sis_term_id is not null and p_account_id is not null then
            self.set_metodo(self.get_metodo || p_sis_term_id || '?account_id=' || to_char(p_account_id));
            return  self.call_request(null, 'Deletar Periodo Academico', r_msg); 
        else
            r_msg := r_msg || CHR(10) || 'Parametros: p_sis_term_id ou p_account_id não informado.';
            return null;
        end if;
    exception
        when others then
            r_msg := 'o_canvas_periodo_academico.deletar' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    /* Buscas */
    member function find_all(SELF IN OUT NOCOPY o_canvas_periodo_academico, p_account_id number default null, p_include varchar2 default null, p_state varchar2 default null, r_log out clob) return pljson_list is
        w_parametros  varchar2(1000);
        w_param_1     varchar2(100) := 'account_id=';
        w_param_2     varchar2(100) := 'include[]=';
        w_param_3     varchar2(100) := 'state=';
    begin

        if p_account_id is not null then
            w_parametros   := '?' || w_param_1 || p_account_id;
        end if;
        
        if p_include is not null then
            if w_parametros like '%?%' then
                w_parametros   := w_parametros || '&' || w_param_2 || p_include;
            else
                w_parametros   := w_parametros || '?' || w_param_2 || p_include;
            end if;
        end if;

        if p_state is not null then
            if w_parametros like '%?%' then
                w_parametros   := w_parametros || '&' || w_param_3 || p_state;
            else
                w_parametros   := w_parametros || '?' || w_param_3 || p_state;
            end if;
        end if;

        if w_parametros is not null then
            self.set_metodo(w_parametros);
            --find_by_method(SELF IN OUT NOCOPY o_canvas, p_metodo varchar2, p_ds_chamada varchar2, has_pagination boolean default false, r_msg out clob)
            return self.find_all(r_log);
        else   
            self.set_metodo(null);
            return self.find_by_method(self.get_metodo, 'Find all periodos academicos', false, r_log);
        end if;
    exception
        when others then
            r_msg := 'o_canvas_periodo_academico.find_all' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;
end;
/
sho err