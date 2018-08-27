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
create or replace type body o_canvas_periodo_academico is

    /* Construtores */
    constructor function o_canvas_periodo_academico return self as result is
    begin
        self.set_default_attribute;
        return;
    end;

    /* Gets and sets */
    member procedure set_default_attribute(SELF IN OUT NOCOPY o_canvas_periodo_academico) is
    begin
        self.set_entidade('terms');
        self.set_metodo('/sis_term_id:');
    end;

    /* Requisições */
    overriding member function inserir_em_lote(SELF IN OUT NOCOPY o_canvas_periodo_academico, p_json clob, r_msg out clob) return pljson is
    begin
        r_msg := '{"error": "este método não existe"}';
    end;

    /* Buscas */
    member function find_all(SELF IN OUT NOCOPY o_canvas_periodo_academico, p_account_id number default null, p_include varchar2 default null, p_state varchar2 default null, r_msg out clob) return pljson_list is
        w_parametros  varchar2(1000);
        w_param_1     varchar2(100) := 'account_id=';
        w_param_2     varchar2(100) := 'include[]=';
        w_param_3     varchar2(100) := 'state=';
        retorno       pljson_list;
        w_msg clob;
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
            retorno := self.find_all(w_msg);
            r_msg := r_msg || chr(10) || w_msg;
            self.set_default;
            return retorno;
        else   
            self.set_metodo(null);
            retorno := self.find_by_method(self.get_metodo, 'Find all periodos academicos', false, w_msg);
            r_msg := r_msg || chr(10) || w_msg;
            self.set_default;
            return retorno;
        end if;
    exception
        when others then
            self.set_default;
            r_msg := r_msg || chr(10) || 'o_canvas_periodo_academico.find_all' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;
end;
/
sho err