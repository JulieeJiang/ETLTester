# encoding: utf-8
#require '../../../lib/etltester'
mapping("ALM_Mapping") do
    
    set_source_connection :oracle_ALM_connection
    #Using declare_source_table keyword to define source table
    declare_dynamic_source_table :sourcetemp do
        check_point_end_time = ETLTester::Util::DBConnection::get_data_from_db(ETLTester::Util::Configuration::get_config(:DBConnection),
            "select max(checkpointendtime) from az.MappingSchemaLoadingAudit where MappingSchemaID=1 and CurrentStatus='succeed'")[0][0].strftime("%Y-%m-%d %H:%M:%S")
            %Q{select distinct bg_bug_id from hpn_hpn_evpg_almig_db.bug,hpn_hpn_evpg_almig_db.audit_log 
                        where bug.bg_user_16 <> 'Task' and bug.bg_user_16 <> 'VOID Record' and bug.bg_user_49 <> '0 - None' 
                        and to_char(bg_bug_id)=au_entity_id and au_time<=to_date('#{check_point_end_time}','YYYY-MM-DD HH24:MI:SS') 
                        and au_action <> 'DELETE'
                        and au_entity_type = 'BUG'
                        and au_time > 
                        (
                        select max(au_time) 
                        from hpn_hpn_evpg_almig_db.audit_log aa 
                        where hpn_hpn_evpg_almig_db.audit_log.au_entity_id = aa.au_entity_id and aa.au_action = 'DELETE' 
                        and aa.au_entity_type = 'BUG')
                    }
    end
    declare_source_table %Q{select * from hpn_hpn_evpg_almig_db.bug},'source'

    source.inner_join sourcetemp, "source.bg_bug_id = sourcetemp.bg_bug_id"
    #Using declare_target_table keyword to define target table
    declare_target_table %Q{select * from dbo.ViewCRReporting where ChangeRequestID in (select changerequestid from dbo.FactChangeRequest where MappingSchemaID='1')},'target'
        
    #define primary(Or uniquer) key's mapping relationship
    mp target.sourceissueid do
        source.bg_bug_id.to_s
    end

    #define state field's mapping relationship
    m target.state do
        source.bg_user_03
        if source.bg_status.gsub(/\s|"/, '').downcase=='New'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Assigned'.gsub(/\s/, '').downcase 
            'Assigned'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='New'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='New'.gsub(/\s/, '').downcase
            'New'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Being Fixed'.gsub(/\s/, '').downcase
            'Being Fixed'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Blocked'.gsub(/\s/, '').downcase
            'Assigned'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='BUg Scrub'.gsub(/\s/, '').downcase
            'Validating Fix'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Fixed Failed'.gsub(/\s/, '').downcase
            'Being Fixed'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Investigating'.gsub(/\s/, '').downcase
            'Investigating'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Monitor'.gsub(/\s/, '').downcase
            'Investigating'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Need More Info'.gsub(/\s/, '').downcase
            'Investigating'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='On Hold'.gsub(/\s/, '').downcase
            'Investigating'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Reopened'.gsub(/\s/, '').downcase
            'Investigating'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Pending Check-in Approval'.gsub(/\s/, '').downcase
            'Being Fixed'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Propose No Fix'.gsub(/\s/, '').downcase
            'Validating Fix'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Root Cause Found'.gsub(/\s/, '').downcase
            'Being Fixed'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Unassigned'.gsub(/\s/, '').downcase
            'New'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Waiting External Feedback'.gsub(/\s/, '').downcase
            'Investigating'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Waiting Partner Fix'.gsub(/\s/, '').downcase
            'Being Fixed'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Waiting Proof of Fix'.gsub(/\s/, '').downcase
            'Validating Fix'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Customer Platforms Verified (Parent Only)'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Verified'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Waiting for Build'.gsub(/\s/, '').downcase
            'Being Fixed'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Waiting for Verification'.gsub(/\s/, '').downcase
            'Fix Integrated'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase
            'Deferred'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='New'.gsub(/\s/, '').downcase && source.bg_user_03.nil?
            'New'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Open'.gsub(/\s/, '').downcase && source.bg_user_03.nil?
            'Investigating'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase && source.bg_user_03.nil?
            'Being Fixed'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase && source.bg_user_03.nil?
            'Deferred'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Closed'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Verified'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Closed'.gsub(/\s/, '').downcase && source.bg_user_03.gsub(/\s|"/, '').downcase=='Closed'.gsub(/\s/, '').downcase && source.bg_user_07.gsub(/\s|"/, '').downcase!='Fixed'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Closed'.gsub(/\s/, '').downcase && source.bg_user_03.nil? && source.bg_user_07.gsub(/\s|"/, '').downcase!='Fixed'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.bg_status.gsub(/\s|"/, '').downcase=='Closed'.gsub(/\s/, '').downcase && source.bg_user_03.nil? && source.bg_user_07.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase
            'Closed'
        else
            if source.bg_status.nil? && source.bg_user_03.nil?
                ''
            elsif source.bg_status.nil? && !source.bg_user_03.nil?
                source.bg_user_03
            elsif !source.bg_status.nil? && source.bg_user_03.nil? 
                source.bg_status
            else
                "#{source.bg_status}/#{source.bg_user_03}"
            end
        end 
    end

    #define engineeringpriority field's mapping relationship            
    m target.engineeringpriority do
        if source.bg_priority.gsub(/\s|"/, '').downcase=='0 - None'.gsub(/\s/, '').downcase
            'None'
        elsif source.bg_priority.gsub(/\s|"/, '').downcase=='1 - Urgent'.gsub(/\s/, '').downcase
            'High'
        elsif source.bg_priority.gsub(/\s|"/, '').downcase=='2 - High'.gsub(/\s/, '').downcase
            'High'
        elsif source.bg_priority.gsub(/\s|"/, '').downcase=='3 - Medium'.gsub(/\s/, '').downcase
            'Medium'
        elsif source.bg_priority.gsub(/\s|"/, '').downcase=='4 - Low'.gsub(/\s/, '').downcase
            'Low'
        elsif source.bg_priority.nil?
            ''
        else
            source.bg_priority
        end
    end

    #define changerequesttype field's mapping relationship
    m target.changerequesttype do
        if source.bg_user_16.gsub(/\s|"/, '').downcase=='Defect'.gsub(/\s/, '').downcase
            'Defect'
        elsif source.bg_user_16.gsub(/\s|"/, '').downcase=='Defect - Released'.gsub(/\s/, '').downcase
            'Defect'
        elsif source.bg_user_16.gsub(/\s|"/, '').downcase=='Defect - Special'.gsub(/\s/, '').downcase
            'Defect'
        elsif source.bg_user_16.gsub(/\s|"/, '').downcase=='Problem'.gsub(/\s/, '').downcase
            'Defect'
        elsif source.bg_user_16.gsub(/\s|"/, '').downcase=='Enhancement'.gsub(/\s/, '').downcase
            'Enhancement'
        elsif source.bg_user_16.gsub(/\s|"/, '').downcase=='New Feature'.gsub(/\s/, '').downcase
            'Enhancement'
        elsif source.bg_user_16.gsub(/\s|"/, '').downcase=='Special'.gsub(/\s/, '').downcase
            'Enhancement'
        elsif source.bg_user_16.nil?
            ''
        else
            source.bg_user_16
        end
    end

    #define customerseverity field's mapping relationship
    m target.customerseverity do
        if source.bg_user_49.gsub(/\s|"/, '').downcase=='1 - Urgent'.gsub(/\s/, '').downcase
            'Critical'
        elsif source.bg_user_49.gsub(/\s|"/, '').downcase=='2 - High'.gsub(/\s/, '').downcase
            'Serious'
        elsif source.bg_user_49.gsub(/\s|"/, '').downcase=='3 - Medium'.gsub(/\s/, '').downcase
            'Medium'
        elsif source.bg_user_49.gsub(/\s|"/, '').downcase=='4 - Low'.gsub(/\s/, '').downcase
            'Low'
        elsif source.bg_user_49.nil?
            ''
        else
            source.bg_user_49
        end
    end

    #define possibilityofcustomeroccurrence field's mapping relationship
    m target.possibilityofcustomeroccurrence do
        if source.bg_user_28.gsub(/\s|"/, '').downcase=='None'.gsub(/\s/, '').downcase
            'N/A'
        elsif source.bg_user_28.gsub(/\s|"/, '').downcase=='High'.gsub(/\s/, '').downcase
            'Always'
        elsif source.bg_user_28.gsub(/\s|"/, '').downcase=='Medium'.gsub(/\s/, '').downcase
            'Very Likely'
        elsif source.bg_user_28.gsub(/\s|"/, '').downcase=='Low'.gsub(/\s/, '').downcase
            'Likely'
        elsif source.bg_user_28.nil?
            ''
        else
            source.bg_user_28
        end
    end

    #define customerencountered field's mapping relationship
    m target.customerencountered do
        case
            when source.BG_USER_TEMPLATE_02.gsub(/\s|"/, '').downcase=='Y'.gsub(/\s/, '').downcase
                'Y'
            when source.BG_USER_TEMPLATE_02.gsub(/\s|"/, '').downcase=='N'.gsub(/\s/, '').downcase
                'N'
            else
                ' '
        end
    end

    #define dispositionclassification field's mapping relationship
    m target.dispositionclassification do
        if source.bg_user_07.gsub(/\s|"/, '').downcase=='As Designed'.gsub(/\s/, '').downcase
            'User Misunderstanding'
        elsif source.bg_user_07.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase
            'Deferred'
        elsif source.bg_user_07.gsub(/\s|"/, '').downcase=='Documentation Issue'.gsub(/\s/, '').downcase
            'Documentation Change'
        elsif source.bg_user_07.gsub(/\s|"/, '').downcase=='Duplicate'.gsub(/\s/, '').downcase
            'Duplicate Problem'
        elsif source.bg_user_07.gsub(/\s|"/, '').downcase=='External Issue'.gsub(/\s/, '').downcase
            '3rd Party Product'
        elsif source.bg_user_07.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase
            'Resolution Implemented'
        elsif source.bg_user_07.gsub(/\s|"/, '').downcase=='Not a Defect'.gsub(/\s/, '').downcase
            'Not a Problem'
        elsif source.bg_user_07.gsub(/\s|"/, '').downcase=='Not Reproducible'.gsub(/\s/, '').downcase
            'Not Reproducible'
        elsif source.bg_user_07.gsub(/\s|"/, '').downcase=='Will Never Fix'.gsub(/\s/, '').downcase
            'Do Not Fix'
        elsif source.bg_user_07.nil?
            ''
        else
            source.bg_user_07
        end
    end

    #define qablocker field's mapping relationship
    m target.qablocker do 
        if source.bg_user_21=='STC Blocker'
            'Y'
        else
            'N'
        end
    end

    #define project field's mapping relationship
    m target.project do 
        if source.bg_user_15.nil?
            ''
        else
            source.bg_user_15
        end        
    end

    #define product field's mapping relationship
    m target.product do
        if source.bg_user_10.nil?
            ''
        else
            source.bg_user_10
        end     
    end

    m target.Organizationunit do
        'HPN'
    end

    m target.foundinstep do
        if source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Backend Rule Checks'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Equivalence Check'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Formal CDC'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Gate Sims - Incoming'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Gate Sims - Outcoming'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Linter'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Mutation Analysis (Certitude)'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PostSil CPU'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PostSil FE'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PostSil HA'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PostSil MAC'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PostSil Other'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PostSil Performance'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil Arch Sim'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil Block Regression'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil Block Sim'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil Cluster Regression'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil Formal Property Verif'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil Functionality Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil Other'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil System Regression'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - PreSil System Sim'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - SVA'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Synthesis'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='ASIC - Timing Analysis (PrimeTime)'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Automation CIT'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Automation Development'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Automation Production Testing'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Automation Validation'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Customer - Beta Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Customer - Normal Usage'.gsub(/\s/, '').downcase
            'Post Release'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Customer - Support Normal Usage'.gsub(/\s/, '').downcase
            'Post Release'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Bring-Up'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Climatics Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - DVT Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - General Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Margin Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Mechanical Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Parametric Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Performance Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Regulatory Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Shock Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Thermal Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Transceiver Qualification'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='HW - Vibration Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Lab - Code Review'.gsub(/\s/, '').downcase
            'Design'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Lab - Design Review'.gsub(/\s/, '').downcase
            'Design'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Lab - Enhancement'.gsub(/\s/, '').downcase
            'Investigation'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Lab - Internal Partner Testing'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Lab - Investigation Review'.gsub(/\s/, '').downcase
            'Investigation'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Lab - Normal Usage'.gsub(/\s/, '').downcase
            'Implementation'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='Lab - Requirements Review'.gsub(/\s/, '').downcase
            'Design'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='MFG - General'.gsub(/\s/, '').downcase
            'Implementation'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='MFG - Lower Level Build'.gsub(/\s/, '').downcase
            'Implementation'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='MFG - Process Qual'.gsub(/\s/, '').downcase
            'Implementation'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='MFG - Upper Level Build'.gsub(/\s/, '').downcase
            'Implementation'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Automated Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Conformance'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Functional/Feature Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - HW Performance and Stress'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Performance Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Readiness Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Scalability Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Security Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Solutions Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - SW Stress Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='STC - Third Party Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Automated Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Component Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Conformance'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Functional/Feature Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Integration Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Internal Early Exposure'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Partner Integration'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Partner Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Performance Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Static Analysis'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.gsub(/\s|"/, '').downcase=='SW - Unit Test'.gsub(/\s/, '').downcase
            'Test'
        elsif source.BG_USER_05.nil?
            ''
        else 
            source.BG_USER_05
        end
    end

    #puts @source_sql_generator.generate_sql
end
