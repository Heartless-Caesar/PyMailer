select DISTINCT s.nr_guia,
                s.cd_solicitacao,
                DECODE(S.CD_SITUACAO,
                       1, 'NEGADA',
                       2, 'APROVADA',
                       3, 'EM ESTUDO',
                       4, 'CANCELADA',
                       5, 'EXECUTADA',
                       6, 'AGUAD.CANC') "SITUACAO",                
                nvl(s.cd_prest_prof_solic, s.CD_PREST_SOLIC) COD_SOLIC,
                NVL(s.NM_PREST_PROF_SOLIC, s.NM_PRESTADOR) NOME_SOLIC,
                TO_CHAR(s.dt_solicitacao, 'DD/MM/yyyy') Dt_solicitacao,
                DECODE(s.cd_unimed, 178, 'LOCAL', 'INTER') UD,
                s.nm_benef,
                DECODE(s.tp_solicitacao,
                       0, 'SADT',
                       1, 'INTERNACAO',
                       2, 'CONSULTA') TIPO_ATEND,
                i.nr_qtd,
                i.cd_item_servico,
                op.ds_item,                
                case
                --MATERIAL/MEDICAMENTO
                  when (op.tp_item = 3 and i.vl_item = 0) then
                   (select t.vl_honorario
                      from ud178.sce_tab_precos_itens     t,
                           datacenter.autsc2_solicitacoes ss
                     where t.cd_item = i.cd_item_servico
                       and ss.cd_solicitacao = s.cd_solicitacao
                       and t.cd_tab_preco = 20000000001
                       and (t.cd_item, t.cd_tab_preco, t.dt_ini_vigencia) in
                           (select tt.cd_item,
                                   tt.cd_tab_preco,
                                   max(tt.dt_ini_vigencia)
                              from ud178.sce_tab_precos_itens tt
                             where tt.dt_ini_vigencia <=
                                   to_date(ss.dt_solicitacao)
                             group by tt.cd_item, tt.cd_tab_preco))                
                --VALOR CONSULTA  
                  when (op.cd_item in (10101012, 10101039) and
                       s.cd_unimed <> 178) then
                   105                
                --PROCEDIMENTO
                  when op.TP_ITEM in (4, 5) then
                   (select --t.vl_honorario
                     sum(t.vl_honorario + t.VL_UCO + VL_FILME)
                      from ud178.sce_tab_precos_itens     t,
                           datacenter.autsc2_solicitacoes ss
                     where t.cd_item = i.cd_item_servico
                       and ss.cd_solicitacao = s.cd_solicitacao
                       and t.cd_tab_preco = 171
                       and (t.cd_item, t.cd_tab_preco, t.dt_ini_vigencia) in
                           (select tt.cd_item,
                                   tt.cd_tab_preco,
                                   max(tt.dt_ini_vigencia)
                              from ud178.sce_tab_precos_itens tt
                             where tt.dt_ini_vigencia <=
                                   to_date(ss.dt_solicitacao)
                             group by tt.cd_item, tt.cd_tab_preco))
                end valor_proced
  from datacenter.autsc2_solicitacoes s,
       datacenter.autsc2_solic_itens  i,
       ud178.SCE_CFG_ITENS            op
 where 1 = 1
   and op.cd_item = i.cd_item_servico
   and i.cd_solicitacao = s.cd_solicitacao
   AND S.CD_UNIMED_SOLIC = 178
   AND S.CD_SITUACAO IN ('2', '5')
   and op.tp_item <> '2' -- taxas e di?rias
   and i.cd_item_servico <> 17801012
   and TO_CHAR(s.dt_solicitacao, 'yyyyMM') = &periodo --informar o periodo base
   AND nvl(s.cd_prest_prof_solic, s.CD_PREST_SOLIC) = 6497 --RETIRAR QUANDO RODAR O TODO
 order by 4, 5, 6
;
---DADOS EMAIL DO PRESTADOR
SELECT TRIM(E.CON_DES_EMAIL) EMAIL,E.*
  FROM DBAUNIMED.PREST P
 INNER JOIN DBAUNIMED.PESSOA_END_CONTAT E
    ON E.PES_COD = P.PREST_COD_PESSOA
 WHERE P.PREST_COD = 779
 AND E.ASS_COD = 1
