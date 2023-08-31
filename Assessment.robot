*** Settings ***
Library  SeleniumLibrary
Variables  customers.yaml



*** Variables ***
${page_url}  https://www.globalsqa.com/angularJs-protractor/BankingProject/#/login
${btn_bank_mgr_login}  //*[@class="btn btn-primary btn-lg" and contains(text(),'Bank Manager Login')]
${btn_customer_login}  //*[@class="btn btn-primary btn-lg" and contains(text(),'Customer Login')]
${btn_add_customer_main}  //*[@ng-class="btnClass1" and contains(text(),"Add Customer")]
${txt_first_name}  //*[contains(@class,'form-control') and contains(@placeholder,'First Name')]
${txt_last_name}  //*[contains(@class,'form-control') and contains(@placeholder,'Last Name')]
${txt_post_code}  //*[contains(@class,'form-control') and contains(@placeholder,'Post Code')]
${btn_add_customer}  //*[@type="submit" and contains(text(),'Add Customer')]
${btn_customers}  //*[@ng-class="btnClass3" and contains(text(),'Customers')]
${btn_deposit}  //button[contains(@ng-class,'btnClass') and contains(text(),'Deposit')]
${btn_submit_deposit}  //button[@type='submit' and contains(text(),'Deposit')]
${btn_submit_withdrawal}  //button[@type='submit' and contains(text(),'Withdraw')]
${btn_login}  //button[contains(text(),'Login')]
${btn_withdrawl}   //button[contains(text(),'Withdrawl')]
${txt_amount}  //input[@type="number" and contains(@placeholder,'amount')]
${lbl_customer_bal}  //div[@ng-hide='noAccount' and contains(string(),'Balance')]/strong[2]

*** Keywords ***
Open Home Page
    [Arguments]  ${url}=${page_url}  ${browser}=chrome
    Open Browser  ${url}  ${browser}


Login As Bank Manager
    Wait Until Element Is Visible   ${btn_bank_mgr_login}   30s
    Click Element   ${btn_bank_mgr_login}    

Login As Customer
    Wait Until Element Is Visible   ${btn_customer_login}   20s
    Click Element   ${btn_customer_login}  


Click Add Customer In Bank Manager
    Wait Until Element Is Visible   ${btn_add_customer_main}   10s
    Click Element    ${btn_add_customer_main}

Enter Customer Details
    [Arguments]  ${first_name}  ${last_name}  ${post_code}
    Wait Until Element Is Visible   ${txt_first_name}   10s
    Input Text    ${txt_first_name}    ${first_name}
    Input Text    ${txt_last_name}    ${last_name}
    Input Text    ${txt_post_code}    ${post_code}  
    Click Element  ${btn_add_customer}
    Handle Alert  action=ACCEPT
    #sleep  2s

Click on Customers Button
    Set Focus To Element  ${btn_customers}
    Click Element  ${btn_customers}


Verify Customer Exists In Grid Table
    [Arguments]  ${first_name}  ${last_name}  ${post_code}
    ${tbl_data}  Set Variable  //td[@class="ng-binding" and contains(text(),'${first_name}')]/following-sibling::*[1][contains(text(),'${last_name}')]/following-sibling::*[1][contains(text(),'${postcode}')]
    Wait Until Element Is Visible  ${tbl_data}
    Page Should Contain Element  ${tbl_data}

Delete Customer
    [Arguments]  ${first_name}  ${last_name}  ${post_code}
    Set Focus To Element  //td[@class="ng-binding" and contains(text(),'${first_name}')]/following-sibling::*[1][contains(text(),'${last_name}')]/following-sibling::*[1][contains(text(),'${postcode}')]/following-sibling::*[2]/button
    Click Element  //td[@class="ng-binding" and contains(text(),'${first_name}')]/following-sibling::*[1][contains(text(),'${last_name}')]/following-sibling::*[1][contains(text(),'${postcode}')]/following-sibling::*[2]/button

Select Customer From Drop-down List
    [Arguments]  ${customer}
    Wait Until Element Is Visible  id:userSelect
    Select From List By Label  id:userSelect  ${customer}

Select Account Number From Drop-down List
    [Arguments]  ${account}
    Wait Until Element Is Visible  id:accountSelect  10s
    Select From List By Label  id:accountSelect  ${account}

Click Login
	[Documentation]  Click login button upon selecting customer from drop-down list
    Wait Until Element Is Visible    ${btn_login} 
    Click Element  ${btn_login} 

Click Deposit
    Wait Until Element Is Visible    ${btn_deposit}   5s
    Click Element  ${btn_deposit} 
    Wait Until Element Is Visible  ${btn_submit_deposit}
	
Click Submit Deposit
    Wait Until Element Is Visible    ${btn_submit_deposit} 
    Click Element  ${btn_submit_deposit}

Click Withdrawl
    Wait Until Element Is Visible    ${btn_withdrawl} 
    Click Element  ${btn_withdrawl} 
    Wait Until Element Is Visible  ${btn_submit_withdrawal}

Click Submit Withdraw
    [Documentation]  To click submit withdraw button
    Wait Until Element Is Visible    ${btn_submit_withdrawal} 
    Click Element  ${btn_submit_withdrawal}

Input Amount
    [Documentation]  To input transaction amount into textbox
    [Arguments]  ${amount}
    Wait Until Element Is Visible    ${txt_amount}     
    Input Text  ${txt_amount}   ${amount}

Get Customer Balance
    [Documentation]  To get customer balance appearing on UI
    ${bal}  Get Text   ${lbl_customer_bal}
    [Return]  ${bal}
 
 
*** Test Cases ***

Test Q1
	[Documentation]  Login as bank manager, add customers and validate all added customers appearing on table. Delete 2 customers from the table
    Open Home Page
    Login As Bank Manager
    Click Add Customer In Bank Manager
    FOR  ${each_customer}  IN  @{CUSTOMERS}
        Log   ${each_customer['firstname']}
        Enter Customer Details  ${each_customer['firstname']}   ${each_customer['lastname']}  ${each_customer['postcode']}
    END
    
    Click on Customers Button
    FOR  ${each_customer}  IN  @{CUSTOMERS}
        Verify Customer Exists In Grid Table  ${each_customer['firstname']}   ${each_customer['lastname']}  ${each_customer['postcode']}
    END   
    
    Delete Customer  Jackson  Frank  L789C349
    Delete Customer  Christopher  Connely  L789C349
    
    #To validate deleted customers no longer appear on table 
    Run Keyword And Expect Error  *  Verify Customer Exists In Grid Table   Jackson  Frank  L789C349
    Run Keyword And Expect Error  *  Verify Customer Exists In Grid Table   Christopher  Connely  L789C349


    
Test Q2
	[Documentation]
    @{transactions}  Create List  50000  -3000  -2000  5000  -10000  -15000  1500  -6000
    ${bal}  Set Variable  0
    Open Home Page   
    Login As Customer
    # sleep  5s
    Select Customer From Drop-down List  Hermoine Granger
    Click Login
    Select Account Number From Drop-down List  1003
    FOR  ${each_entry}  IN  @{transactions}
         ${entry_val_integer}  Evaluate     ${each_entry}   
         ${bal}  Set Variable  ${${bal}+${entry_val_integer}}
         IF   ${entry_val_integer}>0
                Click Deposit
                Input Amount   ${each_entry}
                Click Submit Deposit
        ELSE 
                Click Withdrawl
                Input Amount    ${${0}-${each_entry}}
                Click Submit Withdraw
        END    
    END
    ${bal_on_page}  Get Customer Balance
    Should Be Equal As Strings    ${bal_on_page}    ${bal}
