set define off
create or replace type o_canvas_secao under o_canvas (

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
    *   mycanvas o_canvas := o_canvas_secao;
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
    constructor function o_canvas_secao return self as result,

    /* Gets and sets */
    member procedure set_default_attribute(SELF IN OUT NOCOPY o_canvas_secao),

    /* Requisições */
    /**
    * <p>Criar uma seção</p>
    * <p>Cria uma seção individual e retorna a entidade seção criada.</p>
    * <p>
    *     <table>
    *         <thead>
    *             <tr>
    *                 <td>Campo</td>
    *                 <td>Tipo</td>
    *                 <td>Comentários</td>
    *             </tr>
    *         </thead>
    *         <tbody>
    *             <tr><td>sis_course_id       </td><td>string   </td><td>Código do curso no sistema acadêmico.</td></tr>
    *             <tr><td>name                </td><td>string   </td><td>Nome da seção.</td></tr>
    *             <tr><td>sis_section_id      </td><td>string   </td><td>Código da seção no sistema acadêmico.</td></tr>
    *             <tr><td>start_at            </td><td>datetime </td><td>(opcional) Data de início da seção</td></tr>
    *             <tr><td>end_at              </td><td>datetime </td><td>(opcional) Data de fim da seção</td></tr>
    *             <tr><td>restrict_to_dates   </td><td>boolean  </td><td>(opcional) Restringe as inscrições as datas de inicio e fim da seção. <br>Se este parâmetro não vier definido, assumirá o valor padrão false. Se vier definido como true, será necessário definir as datas de início e fim da seção.</td></tr>
    *             <tr><td>isolate_section     </td><td>boolean  </td><td>Indicador para permitir o isolamento de seções. <br>Para ser definido como true, tem que existir um Conjunto de Grupos chamado <code>GRUPO SECAO</code> criado no curso.</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    <p>
        <code>
            curl -X POST -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
            -d '{
                "course_section":
                {
                    "name":"Nombre de la sección",
                    "end_at":"2017-01-07T02:59:00Z",
                    "start_at":"2016-01-06T03:00:00Z",
                    "sis_section_id":"30952006",
                    "isolate_section": true,
                    "restrict_to_dates": true
                }
            }'
            "https://<apim host and port>/<university>/api/lms/v1/
            courses/sis_course_id:<sis_course_id>/sections"
        </code>
    </p>
    * 
    * @param  p_sis_course_id 1*
    * @param  p_json          2* json (seção) a ser inserido
    * @param  r_msg           log.
    *     
    * @return resposta da requisição.
    */
    member function inserir (SELF IN OUT NOCOPY o_canvas_secao, p_sis_course_id varchar2, p_json varchar2, r_msg out clob) return pljson,

    /**
    * <p>Criar seções</p>
    * <p>Criar um grupo de seções e não retorna informações dentro do corpo da resposta. A criação é diferida e os valores resultantes podem ser consumidos pela fila correspondente ou de retorno de chamada.</p>
    * 
    * <p>
    *     <table>
    *         <thead>
    *             <tr>
    *                 <td>Campo</td>
    *                 <td>Tipo</td>
    *                 <td>Comentários</td>
    *             </tr>
    *         </thead>
    *         <tbody>
    *             <tr><td>sis_course_id       </td><td>string  </td><td> Código do curso no sistema acadêmico.</td></tr>
    *             <tr><td>name                </td><td>string  </td><td> Nome da seção.</td></tr>
    *             <tr><td>sis_section_id      </td><td>string  </td><td> Código da seção no sistema acadêmico.</td></tr>
    *             <tr><td>start_at            </td><td>datetime </td><td>(opcional) Data de início da seção.</td></tr>
    *             <tr><td>end_at              </td><td>datetime </td><td>(opcional) Data de fim da seção</td></tr>
    *             <tr><td>restrict_to_dates   </td><td>boolean  </td><td>(opcional) Restringe as inscrições as datas de inicio e fim da seção. <br>Se este parâmetro não vier definido, assumirá o valor padrão false. Se vier definido como true, será necessário definir as datas de início e fim da seção.</td></tr>
    *             <tr><td>isolate_section     </td><td>boolean </td><td> Indicador para permitir o isolamento de seções. <br>Para ser definido como true, tem que existir um Conjunto de Grupos chamado GRUPO SECAO criado no curso.</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    * 
    * <p>
    *     <code>
    *         curl -X POST -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
    *         -d '[
    *                 {"course_section":
    *                     {
    *                     "sis_course_id" : "023232",
    *                     "name":"Nombre del Curso",
    *                     "end_at":"2017-01-07T02:59:00Z",
    *                     "start_at":"2016-01-06T03:00:00Z",
    *                     "sis_section_id":"30952006",
    *                     "isolate_section": true,
    *                     "restrict_to_dates": true,
    *                     "sis_course_id": "C-101"
    *                     }
    *                 },
    *                 {"course_section":
    *                     {
    *                     "sis_course_id" : "023233",
    *                     "name":"Nombre del Curso",
    *                     "end_at":"2017-01-07T02:59:00Z",
    *                     "start_at":"2016-01-06T03:00:00Z",
    *                     "sis_section_id":"30952002",
    *                     "isolate_section": true,
    *                     "restrict_to_dates": true,
    *                     "sis_course_id": "C-101"
    *                     }
    *                 }
    *             ]'
    *         "https://<apim host and port>/<university>/api/lms/v1/sections/create"
    *     </code>
    * </p>
    * 
    * <p>Valor retornado: 202 - Accepted. Response na fila para cada seção na chamada.</p>
    * <p>
    *     <table>
    *         <thead>
    *             <tr>
    *                 <td>Campo</td>
    *                 <td>Comentários</td>
    *             </tr>
    *         </thead>
    *         <tbody>
    *             <td><td>id              </td><td>Identificador interno gerado.</td></td>
    *             <td><td>sis_section_id  </td><td>Identificador de seção fornecido pelo sistema acadêmico.</td></td>
    *             <td><td>group_id        </td><td>Identificador do grupo vinculado a seção. Só é retornado se o parâmetro isolate_section for true</td></td>
    *             <td><td>sis_course_id   </td><td>ID do Curso fornecido pelo sistema acadêmico</td></td>
    *         </tbody>
    *     </table>
    * </p>
    * 
    * @param  p_json  lista de json a ser enviado.
    * @param  r_msg   log.
    * @return resposta da requisição para cada seção.
    
    member function inserir_secoes  (SELF IN OUT NOCOPY o_canvas_secao, p_json clob    , r_msg out clob) return pljson,*/
    /**
        <p>Atualizar uma Seção</p>
        <p>Atualiza os dados de uma seção</p>

        <p>
            <table>
                <thead>
                    <tr>
                        <td>Campo</td>
                        <td>Tipo</td>
                        <td>Comentários</td>
                    </tr>
                </thead>
                <tbody>
                    <tr><td>old_sis_section_id  </td><td>string      </td><td>(requerido) Código do sistema acadêmico para a seção que pretende atualizar.</td></tr>
                    <tr><td>name                </td><td>string      </td><td>(opcional) Novo nome da seção.</td></tr>
                    <tr><td>sis_section_id      </td><td>string      </td><td>(opcional) Novo código do sistema acadêmico para a seção.</td></tr>
                    <tr><td>start_at            </td><td>datetime    </td><td>(opcional) Nova data de inicio da seção.</td></tr>
                    <tr><td>end_at              </td><td>datetime    </td><td>(opcional) Nova data de fim da seção.</td></tr>
                    <tr><td>restrict_to_dates   </td><td>boolean     </td><td>(opcional) Restringe inscrições para as datas de início e de fim da seção.</td></tr>
                </tbody>
            </table>
        </p>

        <p>
            <code>
                curl -X PUT -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
                -d '{
                    "course_section":
                    {
                        "name":"Nombre de la sección",
                        "sis_section_id":"30952006",
                        "start_at":"2016-01-06T03:00:00Z",
                        "end_at":"2017-01-07T02:59:00Z",
                        "restrict_to_dates": true
                    }
                }'
                "https://<apim host and port>/<university>/api/lms/v1/sections/sis_section_id:<old_sis_section_id>"
            </code>
        </p>

        @param  p_json  seção a ser atualizado
        @param  
    
    member function atualizar (SELF IN OUT NOCOPY o_canvas_secoes, old_sis_section_id varchar2, p_json varchar2, r_msg out clob) return pljson,*/
    
    /**
    * <p>Excluir uma Seção</p>
    * <p>Exclui uma seção e opcionalmente o grupo associado se trabalhar com isolamento de seções.</p>
    *     
    * <p>
    *     <code>
    *         curl -X DELETE -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json" 
    *         "https://<apim host and port>/<university>/api/lms/v1/
    *         sections/sis_section_id:<sis_section_id>?group_id=<group_id>"
    *     </code>
    * </p>    
    * @param  p_sis_section_id    (requerido) Código da seção no sistema acadêmico.
    * @param  p_group_id          (opcional) É o group_id do grupo associado a seção se trabalhar com isolamento de seções.
    *    
    */
    member function deletar         (SELF IN OUT NOCOPY o_canvas_secao, p_sis_section_id varchar2, p_group_id number  default null, r_msg out clob) return pljson,

    /**
    * <p>Liberar e eliminar uma Seção</p>
    * <p>Liberar o SIS_ID de uma seção e eliminá-la em seguida.</p>
    * 
    * <p>
    *     <code>
    *         curl -X DELETE -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json" 
    *         "https://<apim host and port>/<university>/api/lms/v1/
    *         sections/sis_section_id:<sis_section_id>/release"
    *     </code>
    * </p> 
    * 
    * @param  p_sis_section_id    (requerido) Código do sistema acadêmico para a seção a ser eliminada.
    * @return reposta da requisição;
    */
    member function liberar_eliminar(SELF IN OUT NOCOPY o_canvas_secao, p_sis_section_id varchar2, r_msg out clob) return pljson,

    /**
    * <p>Obter detalhes de uma Seção</p>
    * <p>Os detalhes de uma seção específica indicada no parâmetro de consulta são obtidos.</p>
    * <p>
    *     <table>
    *         <thead>
    *             <tr>
    *                 <td>Campo</td>
    *                 <td>Tipo</td>
    *                 <td>Comentários</td>
    *             </tr>
    *         </thead>
    *         <tbody>
    *             <tr><td>sis_section_id 1*</td><td>string  </td><td>ID interno do sistema acadêmico (SIS) atribuído para a seção.</td></tr>
    *             <tr><td>include        2*</td><td>string  </td><td>(opcional) Você pode usar o valor total_students para que a informação seja adicionada do número de alunos do estado: active e invited.</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    * <p>
    *     <code>
    *         curl -X GET -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json"
    *         "https://<apim host and port>/<university>/api/lms/v1/
    *         sections/sis_section_id:<sis_section_id>?include=<include>"
    *     </code>
    * </p>
    * 
    * @param  p_sis_section_id    1*
    * @param  p_include           2*
    * @param  r_msg               log.
    * @return resposta da requisição.
    */
    member function find_by_id(SELF IN OUT NOCOPY o_canvas_secao, p_sis_section_id varchar2, p_include varchar2 default null, r_msg out clob) return pljson_list
    
)NOT FINAL
/
sho err