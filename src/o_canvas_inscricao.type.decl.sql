set define off
create or replace type o_canvas_inscricao under o_canvas (
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
    * <p>Este pacote define o <em>PL/JSON</em>'s representa o objeto type Inscricao</p>
    *
    * <p> Este objeto representa a entidade inscrição (Enrollments) </p>
    *
    * <strong>Exemplo:</strong>
    * <pre>
    * declare
    *   mycanvas o_canvas := o_canvas_inscricao;
    *   w_msg clob;
    * begin
    *   mycanvas.o_canvas.inserir(
    *   '{
    *       "enrollment": {
    *           "user_id": 55,
    *           "type": "StudentEnrollment",
    *           "role_id": 12,
    *           "state": "active",
    *           "limit_interaction": true
    *           "send_notification": false,
    *           "group_id": 1,
    *       }
    *   }', w_msg);
    *   mycanvas.print;
    * end;
    * </pre>
    *
    * @headcom
    */


    /* Construtores */
    constructor function o_canvas_inscricao return self as result,
    /* Gets and sets */
    member procedure set_default_attribute(SELF IN OUT NOCOPY o_canvas_inscricao),

    /* Requisições*/
    /**
    * <p>Criar Inscrição</p>
    * <p>Cria uma inscrição individual e retorna a entidade inscrição criada.</p>
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
    *             <tr><td>user_id             </td><td>integer</td><td> (requerido) ID do usuário a ser inscrito.</td><tr>
    *             <tr><td>type                </td><td>string </td><td>(requerido) Tipo de Inscrição. Os valores possíveis: StudentEnrollment, TeacherEnrollment, TaEnrollment, ObserverEnrollment, DesignerEnrollment</td><tr>
    *             <tr><td>role_id             </td><td>integer</td><td> (opcional) Identificador do role personalizado atribuído a um usuário.</td><tr>
    *             <tr><td>sis_section_id 1*   </td><td>string </td><td>(requerido) ID interno do sistema acadêmico atribuído à seção.</td><tr>
    *             <tr><td>state               </td><td>string </td><td>(requerido) Estado da inscrição. Valores possíveis: active, invited, inactive</td><tr>
    *             <tr><td>limit_interaction   </td><td>boolean</td><td> (requerido) true: Limita a interação somente entre os participantes da seção.</td><tr>
    *             <tr><td>send_notification   </td><td>boolean</td><td> (opcional) Indicador se deve enviar notificações ao usuário.</td><tr>
    *             <tr><td>group_id            </td><td>integer</td><td> (opcional) Identificador do grupo ao qual deseja inscrever.<br>Se não utiliza o group_id poderá não ser enviado como parte do body ou estar presente e vazio.<br>Para utilizar o group_id terá que atribuir ao parâmetro type o valor StudentEnrollment.</td><tr>
    *         </tbody>
    *     </table>
    * </p>
    * <p>
    *     <code>
    *         curl -X POST -H "Authorization: Bearer <Bearer>" -H "Content-Type: application/json"
    *         -d '{
    *             "enrollment": {
    *                 "user_id": 55,
    *                 "type": "StudentEnrollment",
    *                 "role_id": 12,
    *                 "state": "active",
    *                 "limit_interaction": true
    *                 "send_notification": false,
    *                 "group_id": 1,
    *             }
    *         }'
    *         "https://<apim host and port>/<university>/api/lms/v1/
    *         sections/sis_section_id:<sis_section_id>/enrollments"
    *     </code>
    * </p>
    * 
    * 
    * @param  p_sis_section_id    1*.
    * @param  p_json              json inscrioes a ser inserido.
    * @param  r_msg               log.
    */
    member function inserir (SELF IN OUT NOCOPY o_canvas_inscricao, p_sis_section_id varchar2, p_json varchar2, r_msg out clob) return pljson,

    /**
    * <p>Excluir, concluir ou desativar uma Inscrição</p>
    * <p>Dependendo da ação especificada, o serviço pode concluir, inativar ou excluir uma inscrição</p>
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
    *             <tr><td>sis_course_id 1*</td><td>string  </td><td>(requerido) ID interno do SIS que referencia o cursos onde se encontra e inscrição.</td></tr>
    *             <tr><td>enrollment_id 2*</td><td>integer </td><td>(requerido) ID do sistema LMS que identifica a inscrição.</td></tr>
    *             <tr><td>action        3*</td><td>string  </td><td>(requerido) Tarefa a realizar: conclude, delete ou deactivate</td></tr>
    *         </tbody>
    *     </table>
    * </p>
    * <p>
    *     <code>
    *         curl -X DELETE -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json"
    *         "https://<apim host and port>/<university>/api/lms/v1/
    *         courses/sis_course_id:<sis_course_id>/enrollments/<enrollment_id>?task=<action>"
    *         
    *         curl -X DELETE -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json"
    *         "https://<apim host and port>/<university>/api/lms/v1/
    *         courses/sis_course_id:<sis_course_id>/enrollments/<enrollment_id>"
    *         -d task=<action>
    *     </code>
    * </p>
    * @param  p_sis_course_id     1*
    * @param  p_enrollment_id     2*
    * @param  p_action            3*
    * @param  r_msg               log.
    * @return resposta da requisição.
    */
    member function deletar  (SELF IN OUT NOCOPY o_canvas_inscricao, p_sis_course_id varchar2, p_enrollment_id varchar2, p_action varchar2, r_msg out clob) return pljson,

    /**
    * <p>Reativar uma inscrição</p>
    * <p>Reativa uma inscrição desativada.</p>
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
    *             <tr><td>sis_course_id </td><td>string  </td><td>(requerido) ID interno do SIS que referencia o curso onde se encontra a inscrição.</td><tr>
    *             <tr><td>enrollment_id </td><td>integer </td><td>(requerido) ID do sistema LMS que identifica a inscrição.</td><tr>
    *         </tbody>
    *     </table>
    * </p>
    * <p>
    *     <code>
    *         curl -X PUT -H "Authorization: Bearer <bearer>" -H "Content-Type: application/json"
    *         "https://<apim host and port>/<university>/api/lms/v1/
    *         courses/sis_course_id:<sis_course_id>/enrollments/<enrollment_id>/reactivate"
    *         -d '{}'
    *     </code>
    * </p>
    * 
    * @param  p_sis_course_id     1*
    * @param  p_enrollment_id     2*
    * @param  r_msg               log.
    * @return resposta da requisição.
    */
    member function reativar  (SELF IN OUT NOCOPY o_canvas_inscricao, p_sis_course_id varchar2, p_enrollment_id varchar2, r_msg out clob) return pljson
)not final;
/
sho err
