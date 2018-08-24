create or replace type o_canvas_secoes under o_canvas (

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

    /**
    * <p>Este pacote define o <em>PL/JSON</em>'s representa o objeto type da seção</p>
    *
    * <p> Este objeto representa a entidade Seção (Section) </p>
    * <strong>Examplo:</strong>
    * <pre>
    * declare
    *   mycanvas o_canvas := o_canvas_secoes;
    *   secaoInserido pljson;
    *   w_msg clob; 
    * begin
    *   secaoInserido := mycanvas.inserir(
    *   '{
    *       "course_section":
    *       {
    *           "name":"Nombre de la sección",
    *           "end_at":"2017-01-07T02:59:00Z",
    *           "start_at":"2016-01-06T03:00:00Z",
    *           "sis_section_id":"30952006",
    *           "isolate_section": true,
    *           "restrict_to_dates": true
    *       }
    *   }', w_msg);
    *   secaoInserido.print();
    * end;
    * </pre>
    *
    * @headcom
    */

    /* Construtores */
    constructor function o_canvas_secoes return self as result,
    
    member function inserir_secoes  (SELF IN OUT NOCOPY o_canvas_secoes, p_json clob    , r_msg out clob) return pljson,
    member function inserir         (SELF IN OUT NOCOPY o_canvas_secoes, p_json varchar2, r_msg out clob) return pljson,
    member function atualizar       (SELF IN OUT NOCOPY o_canvas_secoes, p_json varchar2, r_msg out clob) return pljson,
    member function deletar         (SELF IN OUT NOCOPY o_canvas_secoes, p_sis_section_id varchar2, p_group_id number  default null, r_msg out clob) return pljson,
    member function liberar_eliminar(p_sis_section_id varchar2, r_msg out clob) return pljson
    
)NOT FINAL
/
create or replace type body o_canvas_secoes is

    /* Construtores */
    constructor function o_canvas_secoes return self as result is
    begin
        self.set_entidade('sections');
        self.set_metodo('/sis_section_id:');
        return;
    end;

    member function inserir_secoes  (SELF IN OUT NOCOPY o_canvas_secoes, p_json clob    , r_msg out clob) return pljson is begin self.set_acao('POST'); return self.call_request(p_json, 'Inserir secoes' , r_msg); end;
    member function inserir         (SELF IN OUT NOCOPY o_canvas_secoes, p_json varchar2, r_msg out clob) return pljson is begin self.set_acao('POST'); return self.call_request(p_json, 'Inserir secao'  , r_msg); end;
    member function atualizar       (SELF IN OUT NOCOPY o_canvas_secoes, p_json varchar2, r_msg out clob) return pljson is begin self.set_acao('PUT');  return self.call_request(p_json, 'Atualizar Secao', r_msg); end;
    
/**
    Excluir uma Seção
    Exclui uma seção e opcionalmente o grupo associado se trabalhar com isolamento de seções.
    
    curl -X DELETE -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json" 
    "https://<apim host and port>/<university>/api/lms/v1/sections/sis_section_id:<sis_section_id>?group_id=<group_id>"
    
    @param  p_sis_section_id    (requerido) Código da seção no sistema acadêmico.
    @param  p_group_id          (opcional) É o group_id do grupo associado a seção se trabalhar com isolamento de seções.
    
*/
    member function deletar (SELF IN OUT NOCOPY o_canvas_secoes, p_sis_section_id varchar2, p_group_id number default null, r_msg out clob) return pljson is
        v_json pljson;
    begin
        self.set_acao('DELETE');
        if p_group_id is not null then
            self.set_metodo(self.get_metodo || p_sis_section_id);
        else
            self.set_metodo(self.get_metodo || p_sis_section_id || '?group_id=' || to_char(p_group_id));
        end if;
        return self.call_request(null, 'Deletar secao', r_msg);
    end;
    
/**
    Liberar e eliminar uma Seção
    Liberar o SIS_ID de uma seção e eliminá-la em seguida.
    
    curl -X DELETE -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json" 
    "https://<apim host and port>/<university>/api/lms/v1/sections/sis_section_id:<sis_section_id>/release"
        
    @param  p_sis_section_id    (requerido) Código do sistema acadêmico para a seção a ser eliminada.
*/
    member function liberar_eliminar(p_sis_section_id varchar2, r_msg out clob) return pljson is
    
    begin
        return null;
        --request(p_json varchar2, p_action varchar2, p_metodo varchar2, p_ds_chamada varchar2, r_json out clob, r_log out clob)
    end;


end;