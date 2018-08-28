<%-- 
    Document   : authorManagement
    Created on : Aug 22, 2018, 3:13:48 PM
    Author     : chee
--%>

<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/utils" prefix="utils"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/pubstyles.css">
    </head>
    <body>
        
        <tg:underConstruction/>
        
        <c:set var="memidnum" value="${param.memidnum}"/>
        <c:set var="paperid" value="${param.paperid}"/>
        <c:set var="leadgrp" value="paper_leads_${paperid}"/>
        
        <c:if test="${!(gm:isUserInGroup(pageContext,$leadgrp) || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,'GroupManagerAdmin'))}">
            <c:redirect url="noPermission.jsp?errmsg=10"/>
        </c:if>  
        
        <sql:query var="pers"> <%-- get requestor info --%>
            select first_name, last_name, user_name, email from profile_user where memidnum = ? and experiment = ?
            <sql:param value="${memidnum}"/>
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
            
        <c:choose>
            <c:when test="${empty param}">
                 <sql:query var="docs">
                    select a.paperid, a.memidnum, a.auth_pos, a.request_status, a.contribution_text, a.contribution_list, a.reason, a.auth_request_date, 
                    a.approved_by, a.modifydate, a.modby, p.title, v.first_name, v.last_name, v.email from 
                    descpub_authorship a join descpub_publication p on a.paperid = p.paperid  join profile_user v on v.memidnum = a.memidnum and v.experiment = 'LSST-DESC'
                    order by auth_request_date
                </sql:query>
                 
                <h2 id="pagelabel">Request(s) For Authorship</h2>
                <display:table class="datatable" id="row" name="${docs.rows}" cellspacing="10" cellpadding="10">
                    <display:column property="auth_request_date" title="Request date" style="text-align:left;" sortable="true" headerClass="sortable"/>
                    <display:column property="first_name" title="First name" style="text-align:left;" url="/GroupManager/exp/${appVariables.experiment}/protected/user.jsp?memidnum=${row.memidnum}" sortable="true" headerClass="sortable"/>
                    <display:column property="last_name" title="Last name" style="text-align:left;" url="/GroupManager/exp/${appVariables.experiment}/protected/user.jsp?memidnum=${row.memidnum}" sortable="true" headerClass="sortable"/>
                    <display:column property="request_status" title="Status" style="text-align:left;" sortable="true" headerClass="sortable"/>
                    <display:column property="approved_by" title="Approved by" style="text-align:left;" sortable="true" headerClass="sortable"/>
                    <display:column title="Manage approval" style="text-align:left;" sortable="true" headerClass="sortable">
                        <a href="authorManagement.jsp?task=form&paperid=${row.paperid}&memidnum=${row.memidnum}">a</a>
                    </display:column>
                    <display:column title="View" style="text-align:left;">
                        <a href="authorManagement.jsp?task=view&paperid=${row.paperid}&memidnum=${row.memidnum}">details</a>
                    </display:column>
                </display:table>
            </c:when>
            <c:when test="${param.task == 'view'}">
                  <sql:query var="docs">
                     select a.paperid, a.memidnum, a.auth_pos, a.request_status, a.contribution_text, a.contribution_list, a.reason, a.auth_request_date, 
                     a.approved_by, a.modifydate, a.modby, p.title, v.first_name, v.last_name, v.email from 
                     descpub_authorship a join descpub_publication p on a.paperid = p.paperid  join profile_user v on v.memidnum = a.memidnum and v.experiment = 'LSST-DESC'
                     where a.paperid = ? and a.memidnum = ?
                     <sql:param value="${paperid}"/>
                     <sql:param value="${memidnum}"/>
                  </sql:query>
                     
                  <a href="authorManagement.jsp">view all</a>
                  <table class="datatable" style="text-align:left;">
                    <utils:trEvenOdd reset="true"><th style="text-align: left;">Requestor's first name</th><td style="text-align: left;">${pers.rows[0].first_name}</td></utils:trEvenOdd>
                    <utils:trEvenOdd><th style="text-align: left;">Requestor's last name</th><td style="text-align: left;">${pers.rows[0].last_name}</td></utils:trEvenOdd>
                    <utils:trEvenOdd><th style="text-align: left;">Requestor's email</th><td style="text-align: left;">${pers.rows[0].email}</td></utils:trEvenOdd>
                    <utils:trEvenOdd><th style="text-align: left;">Date requested</th><td style="text-align: left;">${docs.rows[0].auth_request_date}</td></utils:trEvenOdd>
                    <utils:trEvenOdd><th style="text-align: left;">Title</th><td style="text-align: left;">DESC-${docs.rows[0].title}</td></utils:trEvenOdd>
                    <utils:trEvenOdd><th style="text-align: left;">Contribution statement</th><td style="text-align: left; size=${fn:length(docs.rows[0].contribution_text)}">${docs.rows[0].contribution_text}</td></utils:trEvenOdd>
                    <utils:trEvenOdd><th style="text-align: left;">Check list of contributions</th><td style="text-align: left;">${docs.rows[0].contribution_list}</td></utils:trEvenOdd>
                    <utils:trEvenOdd><th style="text-align: left;">Reason</th><td style="text-align: left;">${docs.rows[0].reason}</td></utils:trEvenOdd>
                    <utils:trEvenOdd><th style="text-align: left;">Status</th><td style="text-align: left;">${docs.rows[0].request_status}</td></utils:trEvenOdd>            
                 </table>
            </c:when>
            <c:when test="${param.task == 'form'}">
                  <h2>Authorship request on DESC-${param.paperid}</h2>
                  <sql:query var="docs">
                     select a.paperid, a.memidnum, a.auth_pos, a.request_status, a.contribution_text, a.contribution_list, a.reason, a.auth_request_date, 
                     a.approved_by, a.modifydate, a.modby, p.title, v.first_name, v.last_name, v.email from 
                     descpub_authorship a join descpub_publication p on a.paperid = p.paperid  join profile_user v on v.memidnum = a.memidnum and v.experiment = 'LSST-DESC'
                     where a.memidnum = ?
                     <sql:param value="${memidnum}"/>
                  </sql:query>
                    
                  <sql:query var="isMem"> <%-- check if user already on author list, e.g. paper_N --%>
                      select ug.user_id, p.first_name, p.last_name from profile_ug ug join profile_user p on ug.memidnum=p.memidnum and ug.experiment = p.experiment
                      where ug.memidnum = ? and ug.group_id = ? and ug.experiment = ?
                      <sql:param value="${memidnum}"/> 
                      <sql:param value="paper_${paperid}"/>
                      <sql:param value="${appVariables.experiment}"/>
                  </sql:query> 
                  
                  <c:if test="${isMem.rowCount > 0}">
                      <p style="color:red" id="pagelabel">${isMem.rows[0].first_name} ${isMem.rows[0].last_name} is already an author </strong> on DESC-${param.paperid}. Submitting this form
                       may change their authorship status. </p>     
                  </c:if>
                   
                  <form action="authorManagement.jsp?paperid=${param.paperid}&memidnum=${param.memidnum}" method="post">
                    <input type="hidden" name="responseSubmitted" value="true"/>
                    <table class="datatable">
                        <utils:trEvenOdd reset="true"><th style="text-align: left;">Requestor's first name</th><td style="text-align: left;"><input type="text" name="fname" value="${pers.rows[0].first_name}" size="100" style="text-align:right;"/></td>
                        </utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Requestor's last name</th><td style="text-align: left;"><input type="text" name="lname" value="${pers.rows[0].last_name}" size="100" style="text-align:right;"/></td>
                        </utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Requestor's email</th><td style="text-align: left;"><input type="text" name="Email" value="${pers.rows[0].email}" size="100" style="text-align:right;"/></td>
                        </utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Date requested</th><td style="text-align: left;"><input type="text" name="auth_request_date" value="${docs.rows[0].auth_request_date}" size="100" style="text-align:right;"/></td></utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Title</th><td>DESC-${docs.rows[0].title}</td></utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Contribution statement</th><td style="text-align: left;"><input type="text" name="contribution_text" value="${docs.rows[0].contribution_text}" size="100" style="text-align:right;" /></td></utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Check list of contributions</th><td style="text-align: left;"><input type="text" name="contribution_list" value="${docs.rows[0].contribution_list}" size="100" style="text-align:right;"/></td></utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Reason</th><td style="text-align: left;"><input type="text" name="reason" value="DESC-${docs.rows[0].reason}" size="100" style="text-align:right;"/></td></utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Response to email to the requestor (limit 4000 chars)</th><td style="text-align: left;"><textarea name="response" rows="20" cols="100" maxlength="4000" required></textarea></td></utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Assign status</th><td style="text-align: left;">              
                            <select name="request_status" ${required}>
                                <option value="approved">Request approved</option>
                                <option value="denied" selected>Request denied</option>
                            </select></td>                         
                        </utils:trEvenOdd>
                        <utils:trEvenOdd><th style="text-align: left;">Send the response</th><td style="text-align: left;"><input type="submit" name="submit" value="submit"/></td></utils:trEvenOdd>
                    </table>
                  </form>
                  
            </c:when>
            <c:when test="${param.responseSubmitted == 'true'}">
                <c:set var="msgbody" value="${param.response}"/>
                <sql:query var="rid">
                    select user_name, first_name, last_name, memidnum, email from profile_user where memidnum = ? and experiment = ?
                    <sql:param value="${param.memidnum}"/>
                    <sql:param value="${appVariables.experiment}"/>
                </sql:query>   
                   
                <c:catch var="trapError">
                    <sql:transaction>
                        <c:if test="${param.request_status == 'approved'}">
                            <sql:update>
                               insert into profile_ug (user_id, group_id, experiment, memidnum) values (?,?,?,?)
                               <sql:param value="${rid.rows[0].user_name}"/>
                               <sql:param value="paper_${param.paperid}"/>
                               <sql:param value="${appVariables.experiment}"/>
                               <sql:param value="${param.memidnum}"/>
                            </sql:update>
                        </c:if>
                        <c:if test="${param.request_status == 'denied'}">
                            <sql:query var="inGrp">
                                select count(*) from profile_ug where group_id = ? and experiment = ? and memidnum = ?
                                <sql:param value="paper_${param.paperid}"/>
                                <sql:param value="${appVariables.experiment}"/>
                                <sql:param value="${rid.rows[0].memidnum}"/>
                            </sql:query>
                            <c:if test="${inGrp.rowCount > 0}">
                                <sql:update>
                                   delete from profile_ug where group_id = ? and experiment = ? and memidnum = ?
                                   <sql:param value="paper_${param.paperid}"/>
                                   <sql:param value="${appVariables.experiment}"/>
                                   <sql:param value="${rid.rows[0].memidnum}"/>
                                </sql:update>
                            </c:if>
                        </c:if>
                        <sql:update var="upd">
                            update descpub_authorship set request_status = ?, approved_by = ?, approval_date = sysdate where paperid = ? and memidnum = ?
                            <sql:param value="${param.request_status}"/>
                            <sql:param value="${userName}"/> 
                            <sql:param value="${param.paperid}"/>
                            <sql:param value="${param.memidnum}"/>
                        </sql:update>

                        <%-- mailbody goes first and gets the sequence--%>
                        <%-- debugging send all email to chee otherwise use memidnum. <sql:param value="${memidnum}  <sql:param value="${rid.rows[0].email} "/> --%>
                        <sql:update>
                            insert into descpub_mailbody (msgid, subject, body, mail_originator, askdate) values(DESCPUB_MAIL_SEQ.nextval, ?, ?, ?,sysdate)
                            <sql:param value="Response to authorship request for DESC-${param.paperid}"/>
                            <sql:param value="${msgbody}"/>
                            <sql:param value="263"/>
                        </sql:update> 

                        <sql:update>
                            insert into descpub_mail_recipient (groupname_or_emailaddr, msgid) values(?,DESCPUB_MAIL_SEQ.currval) 
                            <sql:param value="chee@slac.stanford.edu"/>
                        </sql:update> 
                    </sql:transaction>
                </c:catch>
                <c:choose>
                    <c:when test="${trapError == null}">
                       <p id="pagelabel">Your response has been sent to ${rid.rows[0].first_name} ${rid.rows[0].last_name} at ${rid.rows[0].email} </p>
                    </c:when>
                    <c:when test="${trapError != null}">
                        <p id="pagelabel"> Failed - unable to deliver your response. Reason - <br/>
                            ${trapError}
                        </p>
                    </c:when>
                </c:choose>
            </c:when>
                    
        </c:choose>
    </body>
</html>