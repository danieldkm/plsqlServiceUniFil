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
create or replace type body o_canvas_inscricao is

    /* Construtor */
    constructor function o_canvas_inscricao return self as result is
    begin
        self.set_default_attribute;
        return;
    end;

    /* Gets and sets */
    member procedure set_default_attribute(SELF IN OUT NOCOPY o_canvas_inscricao) is
        tmp pljson;
    begin
        self.set_entidade('enrollments');
        self.set_metodo('/');

        tmp := self.get_variables;
        if tmp.exist('entidade') then
            tmp.remove('entidade');
        end if;
        tmp.put('entidade', self.get_entidade);

        if tmp.exist('metodo') then
            tmp.remove('metodo');
        end if;
        tmp.put('metodo', self.get_metodo);
    end;

    /* Requisições */
    member function inserir (SELF IN OUT NOCOPY o_canvas_inscricao, p_sis_section_id varchar2, p_json varchar2, r_msg out clob) return pljson is
        retorno pljson;
        w_msg clob;
    begin 
        self.set_acao('POST');
        if p_sis_section_id is null then
            r_msg := '{"error": "p_sis_section_id não pode ser nulo"}';
            return null;
        end if;

        if p_json is not null then
            self.set_entidade('sections');
            self.set_metodo(self.get_metodo || 'sis_section_id:'||p_sis_section_id||'/enrollments');
            retorno := self.call_request(p_json, 'Criar Inscrição' , w_msg);
            r_msg := r_msg || chr(10) || w_msg;
            self.set_default;
            return retorno;
        else 
            r_msg := '{"error": "p_json não pode ser nulo"}';
            return null;
        end if;
    exception
        when others then
            self.set_default;
            r_msg := r_msg || chr(10) || 'o_canvas_inscricao.inserir: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    member function deletar  (SELF IN OUT NOCOPY o_canvas_inscricao, p_sis_course_id varchar2, p_enrollment_id varchar2, p_action varchar2, r_msg out clob) return pljson is
        retorno pljson;
        w_msg clob;
    begin 
        self.set_acao('DELETE');
        if p_sis_course_id is null or p_enrollment_id is null or p_action is null then
            r_msg := 
'{
    "error": "p_sis_course_id/p_enrollment_id/p_action não pode ser nulo",
    "p_sis_course_id": "'||p_sis_course_id||'",
    "p_enrollment_id": "'||p_enrollment_id||'",
    "p_action": "'||p_action||'"
}';
            return null;
        end if;

        self.set_entidade('courses');
        self.set_metodo(self.get_metodo || 'sis_course_id:'||p_sis_course_id||'/enrollments/'||p_enrollment_id||'?task='||p_action);
        retorno := self.call_request(null, 'Excluir, concluir ou desativar uma Inscrição', w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        self.set_default;
        return  retorno;
    exception
        when others then
            self.set_default;
            r_msg := r_msg || chr(10) || 'o_canvas_inscricao.deletar' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;

    member function reativar  (SELF IN OUT NOCOPY o_canvas_inscricao, p_sis_course_id varchar2, p_enrollment_id varchar2, r_msg out clob) return pljson is
        retorno pljson;
        w_msg clob;
    begin 
        self.set_acao('PUT');
        if p_sis_course_id is null or p_enrollment_id is null then
            r_msg := 
'{
    "error": "p_sis_course_id/p_enrollment_id não pode ser nulo",
    "p_sis_course_id": "'||p_sis_course_id||'",
    "p_enrollment_id": "'||p_enrollment_id||'"
}';
            return null;
        end if;
        
        self.set_entidade('courses');
        self.set_metodo(self.get_metodo || 'sis_course_id:'||p_sis_course_id||'/enrollments/'||p_enrollment_id||'/reactivate');
        retorno := self.call_request('{}', 'Reativar uma inscrição', w_msg);
        r_msg := r_msg || chr(10) || w_msg;
        self.set_default;
        return retorno;
    exception
        when others then
            self.set_default;
            r_msg := r_msg || chr(10) || 'o_canvas_inscricao.reativar ' || CHR(10) || 'Error:' || util.get_erro;
            return null;
    end;
end;
/
sho err