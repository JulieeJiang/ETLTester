select
    srvr_d.srvr_ky
    , case
        when srvr_d.srvr_ci_lgcl_nm is null then
            -2
        else
            case
                when t1.ASGN_GRP_ORG_HIER_KY is null then
                    0
                else
                    t1.ASGN_GRP_ORG_HIER_KY            
            end
    end IT_ASSET_ASGN_GRP_ORG_HIER_KY
    , case
        when srvr_d.srvr_ci_lgcl_nm is null then
            -2
        else
            case
                when t2.ASGN_GRP_ORG_HIER_KY is null then
                    0
                else
                    t2.ASGN_GRP_ORG_HIER_KY            
            end
    end SUPP_OWN_ASGN_GRP_ORG_HIER_KY
    , case
        when srvr_d.srvr_ci_lgcl_nm is null then
            -2
        else
            case
                when t3.ASGN_GRP_ORG_HIER_KY is null then
                    0
                else
                    t3.ASGN_GRP_ORG_HIER_KY            
            end
    end BUS_OWN_ASGN_GRP_ORG_HIER_KY
    , case
        when srvr_d.srvr_ci_lgcl_nm is null then
            -2
        else
            case
                when t4.EMP_KY is null then
                    0
                else
                    t4.EMP_KY            
            end
    end IT_ASSET_OWN_PERS_KY
    , case
        when srvr_d.srvr_ci_lgcl_nm is null then
            -2
        else
            case
                when t5.EMP_KY is null then
                    0
                else
                    t5.EMP_KY            
            end
    end SUPP_OWN_PERS_KY
    , case
        when srvr_d.srvr_ci_lgcl_nm is null then
            -2
        else
            case
                when t6.EMP_KY is null then
                    0
                else
                    t6.EMP_KY            
            end
    end BUS_OWN_PERS_KY
    , case
        when srvr_d.srvr_ci_lgcl_nm is null then
            -2
        else
            case
                when ci_d.ci_d_ky is null then
                    0
                else
                    ci_d.ci_d_ky            
            end
    end SRVR_CI_KY
from
    (select * from itr23.srvr_d where srvr_d.lgcl_del_fg = 'n') srvr_d
left join
    (SELECT ASGN_GRP_ORG_HIER_D.ASGN_GRP_ORG_HIER_KY, ci.ci_lgcl_nm
    FROM ITR22.CI, ITR23.ASGN_GRP_ORG_HIER_D
    WHERE CI.IT_ASSET_OWN_ORG_HIER_ID = ASGN_GRP_ORG_HIER_D.ASGN_GRP_ORG_HIER_ID(+)
    ) t1 on t1.ci_lgcl_nm = SRVR_D.SRVR_CI_LGCL_NM
 left join
    (SELECT ASGN_GRP_ORG_HIER_D.ASGN_GRP_ORG_HIER_KY, ci_lgcl_nm
     FROM ITR22.CI, ITR23.ASGN_GRP_ORG_HIER_D
     WHERE CI.SUPP_OWN_ORG_HIER_ID = ASGN_GRP_ORG_HIER_D.ASGN_GRP_ORG_HIER_ID(+)
    ) t2 on t2.ci_lgcl_nm = srvr_d.srvr_ci_lgcl_nm
left join
    (SELECT ASGN_GRP_ORG_HIER_D.ASGN_GRP_ORG_HIER_KY, ci_lgcl_nm
    FROM ITR22.CI, ITR23.ASGN_GRP_ORG_HIER_D
    WHERE CI.BUS_OWN_ORG_HIER_ID = ASGN_GRP_ORG_HIER_D.ASGN_GRP_ORG_HIER_ID(+)
    ) t3 on t3.ci_lgcl_nm = srvr_d.srvr_ci_lgcl_nm 
left join
    (SELECT HR_PERS_D.EMP_KY, CI_D.CI_LGCL_NM
FROM ITR23.CI_D, ITR23.HR_PERS_D
WHERE HR_PERS_D.EMAIL_ADDR_NM = SUBSTR(CI_D.IT_ASSET_OWN_CNTCT_TX, 1,DECODE(INSTR(CI_D.IT_ASSET_OWN_CNTCT_TX,','),0,LENGTH(CI_D.IT_ASSET_OWN_CNTCT_TX),INSTR(CI_D.IT_ASSET_OWN_CNTCT_TX,',')-1))
AND HR_PERS_D.EMP_STAT_IND IN ( 'A','L','P')) t4 on t4.CI_LGCL_NM = srvr_d.srvr_ci_lgcl_nm
left join
(SELECT HR_PERS_D.EMP_KY, CI_D.CI_LGCL_NM
FROM ITR23.CI_D, ITR23.HR_PERS_D
WHERE HR_PERS_D.EMAIL_ADDR_NM = SUBSTR(CI_D.SUPP_OWN_EMAIL_NM_LIST_TX, 1,DECODE(INSTR(CI_D.SUPP_OWN_EMAIL_NM_LIST_TX,','),0,LENGTH(CI_D.SUPP_OWN_EMAIL_NM_LIST_TX),INSTR(CI_D.SUPP_OWN_EMAIL_NM_LIST_TX,',')-1))
AND HR_PERS_D.EMP_STAT_IND IN ( 'A','L','P')) t5 on t5.ci_lgcl_nm = srvr_d.srvr_ci_lgcl_nm
left join
(SELECT HR_PERS_D.EMP_KY, CI_D.CI_LGCL_NM
FROM ITR23.CI_D,ITR23.HR_PERS_D
WHERE HR_PERS_D.EMAIL_ADDR_NM = SUBSTR(CI_D.BUS_OWN_EMAIL_NM_LIST_TX,1,DECODE(INSTR(CI_D.BUS_OWN_EMAIL_NM_LIST_TX,','),0,LENGTH(CI_D.BUS_OWN_EMAIL_NM_LIST_TX),INSTR(CI_D.BUS_OWN_EMAIL_NM_LIST_TX
,',')-1))
AND HR_PERS_D.EMP_STAT_IND IN ( 'A','L','P')) t6 on t6.ci_lgcl_nm = srvr_d.srvr_ci_lgcl_nm
left join
    itr23.ci_d on ci_d.ci_lgcl_nm = srvr_d.srvr_ci_lgcl_nm