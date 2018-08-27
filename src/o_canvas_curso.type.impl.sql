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
create or replace type body o_canvas_curso is

    /* Construtores */
    constructor function o_canvas_curso return self as result is
    begin
        self.set_default_attribute;
        return;
    end;

    /* Gets and sets */
    member procedure set_default_attribute(SELF IN OUT NOCOPY o_canvas_curso) is
        tmp pljson;
    begin
        self.set_entidade('courses');
        self.set_metodo('/sis_course_id:');
        self.set_script(self.get_script);
        tmp := pljson('{}');
        tmp.put('entidade', self.entidade);
        tmp.put('script', self.script);
        tmp.put('show_log', self.show_log);
        self.set_variables(tmp);
    end;

    /*
        member function inserir_cursos(SELF IN OUT NOCOPY o_canvas_curso, p_json clob, r_msg out clob) return pljson is 
        begin 
            self.set_acao('POST'); 
            return self.call_request(p_json, 'Inserir cursos' , r_msg); 
        end;

        member function inserir       (SELF IN OUT NOCOPY o_canvas_curso, p_json varchar2, r_msg out clob) return pljson is begin self.set_acao('POST'); return self.call_request(p_json, 'Inserir curso'  , r_msg); end;
        member function atualizar     (SELF IN OUT NOCOPY o_canvas_curso, p_json varchar2, r_msg out clob) return pljson is begin self.set_acao('PUT');  return self.call_request(p_json, 'Atualizar curso', r_msg); end;
    */
    /* Requisições */
    member function concluir(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_action varchar2, r_msg out clob) return pljson is
        retorno pljson;
    begin
        self.set_acao('DELETE');

        if p_sis_course_id is null or p_action is null then
            r_msg := '{"error" : "p_sis_course_id/p_action não pode ser nulo"}';
            return null;
        end if;

        if lower(p_action) not in ('delete', 'conclude') then
            r_msg := '{"error" : "p_action deve ser delete / conclude"}';
            return null;
        end if;

        self.set_metodo(self.get_metodo||p_sis_course_id||'?event='||p_action);
        retorno := self.call_request(null, 'Concluir um curso', r_msg);
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := 'o_canvas.concluir: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
                return null;
    end;

    overriding member function deletar  (SELF IN OUT NOCOPY o_canvas_curso, p_id varchar2, r_msg out clob) return pljson is
    begin
        r_msg := '{"error" : "método não existe para essa entidade"}';
        return null;
    end;

    member function liberar_eliminar(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, r_msg out clob) return pljson is
        retorno pljson;
    begin
        self.set_acao('DELETE');
        if p_sis_course_id is null then
            r_msg := '{"error" : "p_sis_course_id não pode ser nulo"}';
            return null;
        end if;

        self.set_metodo(self.get_metodo||p_sis_course_id||'/release');
        retorno := self.call_request(null, 'Liberar e eliminar um curso', r_msg);
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := 'o_canvas.liberar_eliminar: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
                return null;
    end;

    member function atualizar_configuracoes(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_json varchar2, r_msg out clob) return pljson is
        retorno pljson;
    begin
        self.set_acao('PUT');
        if p_sis_course_id is null or p_json is null then
            r_msg := '{"error" : "p_sis_course_id/p_json não pode ser nulo"}';
            return null;
        end if;
        retorno := pljson(p_json);
        self.set_metodo(self.get_metodo||p_sis_course_id||'/settings');
        retorno := self.call_request(null, 'Atualizar as configurações do Curso', r_msg);
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := 'o_canvas.atualizar_configuracoes: '|| self.get_entidade || CHR(10) || 'Error:' || util.get_erro;
                return null;
    end;
    
    /* Buscas */
    member function find_all(SELF IN OUT NOCOPY o_canvas_curso, p_account_id number default null, p_state varchar2 default null, p_search_term varchar2 default null, p_include varchar2 default null, p_sis_term_id varchar2 default null, r_log out clob) return pljson_list is
        w_parametros  varchar2(1000);
        w_param_1     varchar2(100) := 'account_id=';
        w_param_2     varchar2(100) := 'state=';
        w_param_3     varchar2(100) := 'search_term=';
        w_param_4     varchar2(100) := 'include=';
        w_param_5     varchar2(100) := 'sis_term_id=';
        retorno       pljson_list;
        w_msg         clob;
        procedure set_parametros(p_parametro varchar2, p_param varchar2) is
        begin
            if p_parametro is not null then
                if w_parametros like '%?%' then
                    w_parametros   := w_parametros || '&' || p_param || p_parametro;
                else
                    w_parametros   := w_parametros || '?' || p_param || p_parametro;
                end if;
            end if;
        end;
    begin
        self.set_acao('GET');
        self.set_metodo('');
        if p_account_id is not null then
            w_parametros   := '?' || w_param_1 || p_account_id;
        end if;
        
        set_parametros(p_state      , w_param_2);
        set_parametros(p_search_term, w_param_3);
        set_parametros(p_include    , w_param_4);
        set_parametros(p_sis_term_id, w_param_5);
        r_log := r_log || chr(10) || 'w_parametros:' || w_parametros;
        if w_parametros is not null then
            self.set_metodo(w_parametros);
            retorno := self.find_all(w_msg);
            r_log := r_log || chr(10) || w_msg;
            self.set_default;
            return retorno;
        else   
            self.set_metodo(null);
            retorno := self.find_by_method(self.get_metodo, 'Find all cursos', false, w_msg);
            r_log := r_log || chr(10) || w_msg;
            self.set_default;
            return retorno;
        end if;
    end;

    member function find_sections_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_include varchar2 default null, r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar_secoes  varchar2(100) := '/sections';
        w_param_1               varchar2(100)  := 'include=<include>';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_secoes;
        
        if p_include is not null then
            w_parametros   := w_parametros || '?' || replace(w_param_1, '<include>', p_include);
        end if;

        w_metodo := self.entidade || w_parametros;
        retorno := self.find_by_method(w_metodo, 'find_section_by_id', r_msg => w_log);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                w_log := w_log || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(w_log, p_debug => true);
                end if;
                return null;
    end;
    
    /* Inscrições */
    member function find_enrollments_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_role varchar2 default null, p_state varchar2 default null, r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar_inscricoes  varchar2(100) := '/enrollments';
        w_param_1                   varchar2(100) := 'role=<role>';
        w_param_2                   varchar2(100) := 'state=<state>';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_inscricoes;
        
        if p_role is not null then
            w_parametros   := w_parametros || '?' || replace(w_param_1, '<role>', p_role);
        end if;
        
        if p_state is not null then
            if w_parametros like '%?%' then
                w_parametros   := w_parametros || '&' || replace(w_param_2, '<state>', p_state);
            else
                w_parametros   := w_parametros || '?' || replace(w_param_2, '<state>', p_state);
            end if;
        end if;

        w_metodo := self.entidade || w_parametros;
        retorno := self.find_by_method(w_metodo, 'Listar inscrições em um Curso', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(r_msg, p_debug => true);
                end if;
                return null;
    end;

    /* Atividades - Assignments */
    member function find_assignments_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_search_term varchar2 default null, p_only_gradable_assignments boolean default false, r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar_atividades  varchar2(100) := '/assignments';
        w_param_1                   varchar2(100)  := 'search_term=<search_term>';
        w_param_2                   varchar2(100)  := 'only_gradable_assignments=<only_gradable_assignments>';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_atividades;
        if p_search_term is not null then
            w_parametros   := w_parametros || '?' || replace(w_param_1, '<search_term>', p_search_term);
        end if;
        if p_only_gradable_assignments then
            if w_parametros like '%?%' then
                w_parametros   := w_parametros || '&' || replace(w_param_2, '<only_gradable_assignments>', 'true');
            else
                w_parametros   := w_parametros || '?' || replace(w_param_2, '<only_gradable_assignments>', 'true');
            end if;
        end if;

        w_metodo := self.entidade || w_parametros;
        retorno := self.find_by_method(w_metodo, 'find_assignments_by_id', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(w_log, p_debug => true);
                end if;
                return null;
    end;
    
    /* Cursos Modelo (BluePrint Courses) */
    member function find_blueprint_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_template_id varchar2 default 'default', r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar_atividades  varchar2(100) := '/blueprint';
        w_param_1                   varchar2(100)  := 'template_id:';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_atividades;
        
        if p_template_id is not null then
            w_parametros   := w_parametros || '/' || w_param_1 || p_template_id;
        end if;

        w_metodo := self.entidade || w_parametros;
        retorno :=self.find_by_method(w_metodo, 'find_blueprint_by_id', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(r_msg, p_debug => true);
                end if;
                return null;
    end;

    member function find_blueprint_associate_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_template_id varchar2 default 'default', r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar_atividades  varchar2(100) := '/blueprint';
        w_param_1                   varchar2(100)  := 'template_id:';
        retorno pljson_list;

    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_atividades;
        
        if p_template_id is not null then
            w_parametros   := w_parametros || '/' || w_param_1 || p_template_id || '/associated_courses';
        end if;

        w_metodo := self.entidade || w_parametros;
        retorno := self.find_by_method(w_metodo, 'find_blueprint_associate_by_id', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(r_msg, p_debug => true);
                end if;
                return null;
    end;

    member function find_blueprint_migrate_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_template_id varchar2 default 'default', r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar_atividades  varchar2(100) := '/blueprint';
        w_param_1                   varchar2(100)  := 'template_id:';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_atividades;
        
        if p_template_id is not null then
            w_parametros   := w_parametros || '/' || w_param_1 || p_template_id || '/migrate';
        end if;

        w_metodo := self.entidade || w_parametros;
        retorno := self.find_by_method(w_metodo, 'find_blueprint_migrate_by_id', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(r_msg, p_debug => true);
                end if;
                return null;
    end;
  
    member function find_bp_migration_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_template_id varchar2 default 'default', p_migration_id varchar2, r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar_atividades  varchar2(100) := '/blueprint';
        w_param_1                   varchar2(100)  := 'template_id:';
        w_param_2                   varchar2(100)  := 'migration_id:';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_atividades;
        
        if p_template_id is not null then
            w_parametros   := w_parametros || '/' || w_param_1 || p_template_id || '/migrate';
        end if;
        
        w_parametros   := w_parametros || '/' || w_param_2 || p_migration_id;

        w_metodo := self.entidade || w_parametros;
        retorno :=self.find_by_method(w_metodo, 'find_blueprint_migration_by_id', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(r_msg, p_debug => true);
                end if;
                return null;
    end;
    
    member function find_bp_migration_detail_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_template_id varchar2 default 'default', p_migration_id varchar2, r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar_atividades  varchar2(100) := '/blueprint';
        w_param_1                   varchar2(100)  := 'template_id:';
        w_param_2                   varchar2(100)  := 'migration_id:';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_atividades;
        
        if p_template_id is not null then
            w_parametros   := w_parametros || '/' || w_param_1 || p_template_id || '/migrate';
        end if;
        
        w_parametros   := w_parametros || '/' || w_param_2 || p_migration_id || '/details';

        w_metodo := self.entidade || w_parametros;
        retorno := self.find_by_method(w_metodo, 'find_migration_detail_by_id', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(r_msg, p_debug => true);
                end if;
                return null;
    end;
    
    member function find_bp_subscription_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, p_subscription_id varchar2 default 'default', r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);
        w_metodo_listar_atividades  varchar2(100) := '/blueprint';
        w_param_1                   varchar2(100)  := 'subscription_id:';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar_atividades;
        
        if p_subscription_id is not null then
            w_parametros   := w_parametros || '/' || w_param_1 || p_subscription_id || '/migrate';
        end if;
        
        w_metodo := self.entidade || w_parametros;
        retorno := self.find_by_method(w_metodo, 'find_bp_subscription_by_id', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(r_msg, p_debug => true);
                end if;
                return null;
    end;
   
    /* Conjuntos de Grupos */
    member function find_group_by_id(SELF IN OUT NOCOPY o_canvas_curso, p_sis_course_id varchar2, r_msg out clob) return pljson_list is
        w_log         clob;
        w_metodo      varchar2(1000);
        w_parametros  varchar2(1000);

        w_metodo_listar  varchar2(100) := '/group_categories';
        retorno pljson_list;
    begin
        self.set_acao('GET');
        w_parametros := self.get_metodo || p_sis_course_id || w_metodo_listar;
                
        w_metodo := self.entidade || w_parametros;
        retorno := self.find_by_method(w_metodo, 'find_group_by_id', r_msg => r_msg);
        r_msg := r_msg || chr(10) || w_log;
        self.set_default;
        return retorno;
        exception
            when others then
                self.set_default;
                r_msg := r_msg || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(r_msg, p_debug => true);
                end if;
                return null;
    end;

    member function create_group(SELF IN OUT NOCOPY o_canvas_curso, p_json varchar2, p_sis_course_id varchar2, r_msg out clob) return pljson is
        w_log       clob;
        w_msg       clob;
        w_resposta  clob;
        retorno     pljson;
    begin
        self.set_acao('GET');
        w_log      := 'Inicio: Criar um conjunto de grupos';
        w_log      := w_log || chr(10) || 'Entidade: ' || self.get_entidade;
        
        self.request(p_json, 'POST', '/'||self.get_entidade || self.get_metodo || p_sis_course_id || '/group_categories', 'Criar um conjunto de grupos', w_resposta, w_msg);
        
        w_log := w_log || chr(10) || w_msg;
        
        self.set_default;
        r_msg := w_log;
        if w_resposta is not null and w_resposta like '{%' then
            return pljson(w_resposta);
        else
            return null;
        end if;
    exception
            when others then
                self.set_default;
                w_log := w_log || chr(10) || util.get_erro;
                if self.get_show_log then
                    util.plob(w_log, p_debug => true);
                end if;
                r_msg := w_log;
                return null;
    end;
    
    member procedure controller(p_sql in varchar2, is_batch in boolean, p_verify_id in boolean, r_msg out clob) is
    begin null; 
        /*w_course_id  varchar2(100);
        l_exist      boolean;
        js_cursos    clob;
        w_lista_json clob;
        w_msg        clob;
        w_msg2       clob;
        jl_cursos    pljson_list;
        l_courses    r_cursos;
        
        procedure atualizar_tabela(p_canvas_id varchar2, p_course_id varchar2) is
        begin
            r_msg := r_msg || chr(10) || 'update canvas_cursos set dt_incl = '||sysdate||', canvas_id = '||p_canvas_id||' where sis_course_id = '||p_course_id;
            update canvas_cursos set dt_incl = sysdate, canvas_id = p_canvas_id where sis_course_id = p_course_id;
            
            if sql%rowcount > 0 then
                r_msg := r_msg || chr(10) || 'Atualizou canvas_cursos ('||p_course_id||')';
            else
                raise e_curso_not_update;
            end if;
        end;
    begin
--        r_msg := 'Inicio - inserindo cursos';
        if lower(p_sql) like '%"course"%' then
            controller_save_request(util_all_atribute_to_upper(p_sql), 'courses', 'Cursos', 'course', 'canvas_cursos', json_template_course, is_batch, p_verify_id, w_msg, 'courses?account_id=118&search_term=<sis_course_id>'); --'users?search_term=<sis_user_id>'
            r_msg := r_msg || chr(10) || w_msg;
        else
            r_msg := r_msg || chr(10) || 'Converter sql em lista de json';
            jl_cursos := JSON_UTIL_PKG.SQL_TO_JSON(p_sql);
            r_msg := r_msg || chr(10) || 'Quantidade: '||jl_cursos.count;
--            if (is_batch) then
--                raise e_batch_not_found;
--            else
                r_msg := r_msg || chr(10) || 'Criar vários cursos, requisição individual: courses';
                
                for i in 1..jl_cursos.count loop
                    declare
                        l_variables varchar2(100);
                        js_curso    pljson;
                    begin
                        r_msg := r_msg || chr(10) || '-----------------------------------------------------------------------------';
                        js_cursos := jl_cursos.get(i).to_char(false);
                        js_cursos := replace(js_cursos, 'null', '""');
                        
                        js_curso := util_remove_empty_column(json(js_cursos));
--                        js_curso := json(js_cursos);
                        if js_curso.exist('PUBLISH') then
                            l_variables := ',"PUBLISH":';
                            if js_curso.get('PUBLISH').typeval = 5 then
                                if js_curso.get('PUBLISH').get_bool then
                                    l_variables := l_variables||'true';
                                else
                                    l_variables := l_variables||'false';
                                end if;
                            elsif js_curso.get('PUBLISH').typeval = 3 then
                                l_variables := l_variables||rtrim(js_curso.get('PUBLISH').str);
                            end if;
                            js_curso.remove('PUBLISH');
                        end if;
                        if js_curso.exist('IMPORT_CONTENT') then
                            l_variables := l_variables||',"IMPORT_CONTENT":';
                            if js_curso.get('IMPORT_CONTENT').typeval = 5 then
                                if js_curso.get('IMPORT_CONTENT').get_bool then
                                    l_variables := l_variables||'true';
                                else
                                    l_variables := l_variables||'false';
                                end if;
                            elsif js_curso.get('IMPORT_CONTENT').typeval = 3 then
                                l_variables := l_variables||js_curso.get('IMPORT_CONTENT').str;
                            end if;
                            js_curso.remove('IMPORT_CONTENT');
                        end if;
                        js_cursos := '{"COURSE":'||js_curso.to_char(false)||l_variables||'}';
                        l_exist := false;
                        if p_verify_id then
                            w_course_id := js_curso.get('SIS_COURSE_ID').STR;
                            r_msg := r_msg || chr(10) || 'Buscar curso ('||w_course_id||')';
                            w_msg := dao_find_all('courses?account_id=118&search_term='||w_course_id, r_msg => w_msg2);
                            r_msg := r_msg || chr(10) || w_msg2;
                            r_msg := r_msg || chr(10) || 'Resultado:'||w_msg;
                            l_courses := get_courses(w_msg);
                            for i in 1..l_courses.count loop
                                r_msg := r_msg || chr(10) || w_course_id || '='||UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(l_courses(i).sis_course_id, keep_words));
                                if w_course_id = UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(l_courses(i).sis_course_id, keep_words)) then
                                    r_msg := r_msg || chr(10) || 'Curso já existe ('||w_course_id||')';
                                    atualizar_tabela(UTIL.REMOVE_LINES(UTIL.REMOVE_ALL_SPECIAL_CHARACTER(l_courses(i).canvas_id, keep_words)), w_course_id);
                                    l_exist := true;
                                end if;
                            end loop;
                        end if;
                        if not l_exist then
--                            if not(util_validate_json(json_template_course, js_cursos)) and i = 1 then
--                                raise e_formato_json_invalido;
--                            else
                            if is_batch then--TODO aqui ainda não foi finalizado
                                if  jl_cursos.count = i then
                                    w_lista_json := w_lista_json ||','||util_all_atribute_to_lower(js_cursos)||']';
                                elsif w_lista_json is not null then
                                    w_lista_json := w_lista_json|| ','||util_all_atribute_to_lower(js_cursos);
                                else
                                    w_lista_json := '['||util_all_atribute_to_lower(js_cursos);
                                end if;
                            else
                                controller_save_request(js_cursos, 'courses', 'Cursos', 'course', 'canvas_cursos', json_template_course, is_batch, p_verify_id, w_msg, 'courses?account_id=118&search_term=<sis_course_id>'); --'users?search_term=<sis_user_id>'
                                r_msg := r_msg || chr(10) || w_msg;
                            end if;
--                            end if;
                        end if;
                    exception
                        when e_curso_not_update then
                            r_msg := r_msg || chr(10) || replace(msg_e_curso_not_update, 'dado', '');
                        when e_formato_json_invalido then
                            r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', js_cursos);
                            exit;
                        when others then
                            r_msg := r_msg || chr(10) || 'Inicio Erro:';
                            r_msg := r_msg || chr(10) || util.get_erro;
                            r_msg := r_msg || chr(10) || 'Fim Erro';
                    end;
                end loop;
                if is_batch and upper(r_msg) not like '%ERRO%' then
                    controller_save_request(w_lista_json, 'courses', 'Cursos', 'course', 'canvas_cursos', json_template_course, is_batch, p_verify_id, w_msg, 'courses?account_id=118&search_term=<sis_course_id>'); --'users?search_term=<sis_user_id>'
                    r_msg := r_msg || chr(10) || w_msg;
                end if;
--                r_msg := r_msg || chr(10) || 'Inserido: '||qt_inserido;
--            end if;
        end if;
        r_msg := r_msg || chr(10) || 'Fim - inserindo cursos';
        exception
            when e_batch_not_found then
                r_msg := r_msg || chr(10) || replace(msg_e_batch_not_found, 'dado', '');
                r_msg := r_msg || chr(10) || 'Fim - inserindo cursos';
            when e_formato_json_invalido then
                r_msg := r_msg || chr(10) || replace(msg_e_formato_json_invalido, 'dado', js_cursos);
                r_msg := r_msg || chr(10) || 'Fim - inserindo cursos';
            when others then
                r_msg := r_msg || chr(10) || 'Inicio Erro:';
                r_msg := r_msg || chr(10) || util.get_erro;
                r_msg := r_msg || chr(10) || 'Fim Erro';
                r_msg := r_msg || chr(10) || 'Fim - inserindo cursos';*/
    end;
end;
/
sho err