set define off
create or replace type o_canvas_periodo_academico under o_canvas (

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
    * <p>Este pacote define o <em>PL/JSON</em>'s representa o objeto type principal do canvas</p>
    *
    * <p> Este objeto representa a entidade Período Academico (Terms) </p>
    * <strong>Examplo:</strong>
    * <pre>
    * declare
    *   mycanvas o_canvas := o_canvas_periodo_academico;
    *   resposta pljson;
    *   w_msg clob; 
    * begin
    *   resposta := mycanvas.inserir(
    *   '{
    *       "term": {
    *           "account_id": "1",
    *           "sis_term_id": "Sp2014",
    *           "name": "Spring 2014",
    *           "start_at": "2016-01-10T18:48:00Z",
    *           "end_at": "2017-01-10T18:48:00Z",
    *           "student_start_at": "2017-07-12T03:00:00Z",
    *           "student_end_at": "2017-07-12T03:00:00Z",
    *           "teacher_start_at": "2017-07-12T03:00:00Z",
    *           "teacher_end_at": "2017-07-23T02:59:59Z",
    *           "assistant_start_at": "2017-07-23T02:59:59Z",
    *           "assistant_end_at": "2017-07-23T02:59:59Z",
    *           "designer_start_at": "2017-07-11T03:00:00Z",
    *           "designer_end_at": "2017-07-16T02:59:59Z"
    *       }
    *   }', w_msg);
    *   resposta.print;
    * end;
    * </pre>
    *
    * @headcom
    */

    /* Construtores */
    constructor function o_canvas_periodo_academico return self as result,

    /* Gets and sets */
    member procedure set_default_attribute(SELF IN OUT NOCOPY o_canvas_periodo_academico),

    /* Requisições */
    overriding member function inserir_em_lote(SELF IN OUT NOCOPY o_canvas_periodo_academico, p_json clob, r_msg out clob) return pljson,
    /**
    * <p>Criar um Período Acadêmico</p>
    * <p>Criar uma nova períodos acadêmicos ou ciclos acadêmicos.</p>
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
    *             <tr>
    *                 <td>name</td>
    *                 <td>string</td>
    *                 <td>(requerido) Nome completo.</td>
    *             </tr>
    *             <tr>
    *                 <td>sis_term_id</td>
    *                 <td>string</td>
    *                 <td>(requerido) Período acadêmico identificador dentro do sistema.</td>
    *             </tr>
    *             <tr>
    *                 <td>start_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de início do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>end_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de fim do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>student_start_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de inicio para os estudantes no nível do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>student_end_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de fim para os estudantes no nível do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>teacher_start_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de inicio para os professores no nível do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>teacher_end_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de fim para os professores no nível do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>assistant_start_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de inicio para os professores assistentes no nível do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>assistant_end_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de fim para os professores assistentes no nível do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>designer_start_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de inicio para os designers no nível do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>designer_end_at</td>
    *                 <td>date</td>
    *                 <td>(opcional) Data de fim para os designers no nível do período acadêmico.</td>
    *             </tr>
    *             <tr>
    *                 <td>account_id</td>
    *                 <td>integer</td>
    *                 <td>(opcional) ID da conta de onde pretende para criar o período acadêmico. Se o parâmetro não é enviado, por padrão, a conta root é assumido.</td>
    *             </tr>
    *         </tbody>
    *     </table>
    * <p>
    * <p>
    *     <code>
    *         curl -X POST -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
    *         -d 
    *         '{
    *             "term": {
    *                 "account_id": "1",
    *                 "sis_term_id": "Sp2014",
    *                 "name": "Spring 2014",
    *                 "start_at": "2016-01-10T18:48:00Z",
    *                 "end_at": "2017-01-10T18:48:00Z",
    *                 "student_start_at": "2017-07-12T03:00:00Z",
    *                 "student_end_at": "2017-07-12T03:00:00Z",
    *                 "teacher_start_at": "2017-07-12T03:00:00Z",
    *                 "teacher_end_at": "2017-07-23T02:59:59Z",
    *                 "assistant_start_at": "2017-07-23T02:59:59Z",
    *                 "assistant_end_at": "2017-07-23T02:59:59Z",
    *                 "designer_start_at": "2017-07-11T03:00:00Z",
    *                 "designer_end_at": "2017-07-16T02:59:59Z"
    *             }
    *         }' "https://<apim host and port>/<university>/api/lms/v1/terms"
    *     </code>
    * </p>
    *     
    * @param  p_json  json a ser enviado.
    * @param  r_msg   log.
    * @return resposta da requisição.
    *  
    member function inserir  (SELF IN OUT NOCOPY o_canvas_periodo_academico, p_json varchar2, r_msg out clob) return pljson,*/
    
    /**
    * <p>Atualizar Período Acadêmico</p>
    * <p>Atualiza os dados de um período acadêmico.</p>
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
    *             <tr><td>name                </td><td>string      </td><td>(requerido) Nome completo.</td></tr>
    *             <tr><td>old_sis_term_id     </td><td>string      </td><td>(requerido) ID interno do sistema acadêmico (SIS) atribuído ao período acadêmico.</td></tr>
    *             <tr><td>sis_term_id         </td><td>string      </td><td>(opcional) Novo ID interno del sistema acadêmico (SIS) atribuído ao período acadêmico.</td></tr>
    *             <tr><td>start_at            </td><td>datetime    </td><td>(opcional) Data de início do período acadêmico.</td></tr>
    *             <tr><td>end_at              </td><td>datetime    </td><td>(opcional) Data de fim do período acadêmico.</td></tr>
    *             <tr><td>student_start_at    </td><td>datetime    </td><td>(opcional) Data de inicio para os estudantes no nível do período acadêmico.</td></tr>
    *             <tr><td>student_end_at      </td><td>datetime    </td><td>(opcional) Data de fim para os estudantes no nível do período acadêmico.</td></tr>
    *             <tr><td>teacher_start_at    </td><td>datetime    </td><td>(opcional) Data de inicio para os professores no nível do período acadêmico.</td></tr>
    *             <tr><td>teacher_end_at      </td><td>datetime    </td><td>(opcional) Data de fim para os professores no nível do período acadêmico.</td></tr>
    *             <tr><td>assistant_start_at  </td><td>datetime    </td><td>(opcional) Data de inicio para os professores assistentes no nível do período acadêmico.</td></tr>
    *             <tr><td>assistant_end_at    </td><td>datetime    </td><td>(opcional) Data de fim para os professores assistentes no nível do período acadêmico.</td></tr>
    *             <tr><td>designer_start_at   </td><td>datetime    </td><td>(opcional) Data de inicio para os designers no nível do período acadêmico.</td></tr>
    *             <tr><td>designer_end_at     </td><td>datetime    </td><td>(opcional) Data de fim para os designers no nível do período acadêmico.</td></tr>
    *             <tr><td>account_id          </td><td>integer     </td><td>(opcional) ID da conta de onde pretende para atualizar o período acadêmico. Se o parâmetro não é enviado, por padrão, a conta root é assumido.</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    * <p>
    *     <code>
    *         curl -X PUT -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
    *         -d 
    *         '{
    *             "term": {
    *                 "account_id": "1",
    *                 "sis_term_id": "Sp2014",
    *                 "name": "Spring 2014",
    *                 "start_at": "2016-01-10T18:48:00Z",
    *                 "end_at": "2017-01-10T18:48:00Z",
    *                 "student_start_at": "2017-07-12T03:00:00Z",
    *                 "student_end_at": "2017-07-12T03:00:00Z",
    *                 "teacher_start_at": "2017-07-12T03:00:00Z",
    *                 "teacher_end_at": "2017-07-23T02:59:59Z",
    *                 "assistant_start_at": "2017-07-23T02:59:59Z",
    *                 "assistant_end_at": "2017-07-23T02:59:59Z",
    *                 "designer_start_at": "2017-07-11T03:00:00Z",
    *                 "designer_end_at": "2017-07-16T02:59:59Z"
    *             }
    *         }' "https://<apim host and port>/<university>/api/lms/v1/terms/sis_term_id:<old_sis_term_id>"
    *     </code>
    * </p>
    *
    * @param  p_old_sis_term_id   term_id a ser atualizado.
    * @param  p_json              json a ser enviado.
    * @param  r_msg               log.
    * @return resposta da requisição.
    
    member function atualizar (SELF IN OUT NOCOPY o_canvas_periodo_academico, p_old_sis_term_id varchar2, p_json varchar2, r_msg out clob) return pljson,*/

    /**
    * <p>Excluir um Período Acadêmico.</p>
    * <p>Exclui dados de um período acadêmico.</p>
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
    *             <tr><td>account_id*1    </td><td>integer </td><td>(requerido) ID da conta em que o período acadêmico está criado.</td></tr>
    *             <tr><td>sis_term_id*2   </td><td>string  </td><td>(requerido) ID interno do sistema acadêmico (SIS) designado para o período acadêmico.</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    * <p>
    *     <code>
    *         curl -X DELETE -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json"
    *         "https://<apim host and port>/<university>/api/lms/v1/terms/sis_term_id:<sis_term_id>?account_id=<account_id>"
    *     </code>
    * </p>
    *            
    * @param  p_sis_term_id   *1
    * @param  p_account_id    *2
    * @return resposta da requisição.
    
    member function deletar  (SELF IN OUT NOCOPY o_canvas_periodo_academico, p_sis_term_id varchar2, p_account_id number, r_msg out clob) return pljson,*/

    /* Buscas */
    /**
    * <p>Listar Períodos Acadêmicos</p>
    * <p>Lista todos os períodos acadêmicos ou ciclos acadêmicos previamente criadas dentro da conta.</p>
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
    *             <tr><td>account_id*1  </td><td>integer </td><td>(opcional) ID da conta de onde você quer para listar os períodos letivos. Se o parâmetro não é enviado, por padrão, a conta root é assumido.<td></tr>
    *             <tr><td>state*2       </td><td>string  </td><td>(opcional) Valores permitidos: active, deleted, all<td></tr>
    *             <tr><td>include*3     </td><td>string  </td><td>(opcional) Se o valor permitido é enviado, em seguida, os detalhes das datas de cada tipo de papel traz. Valor permitido: overrides<td></tr>
    *         </tbody>
    *     </table>
    * </p>
    * <p>
    *     <code>
    *         curl -X GET -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json"
    *         "https://<apim host and port>/<university>/api/lms/v1/terms?include[]=<include>&state=<state>"
    *     </code>
    * </p>
    * 
    * @param  p_account_id    *1
    * @param  p_include       *3
    * @param  p_state         *2
    * @return resposta da requisição.
    */
    member function find_all (SELF IN OUT NOCOPY o_canvas_periodo_academico, p_account_id number default null, p_include varchar2 default null, p_state varchar2 default null, r_msg out clob) return pljson_list
)NOT FINAL
/
sho err