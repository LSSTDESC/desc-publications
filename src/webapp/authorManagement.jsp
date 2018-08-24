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
        
        <sql:query var="docs">
            select a.paperid, a.memidnum, a.auth_pos, a.request_status, a.contribution_text, a.contribution_list, a.reason, a.auth_request_date, 
            a.approved_by, a.modifydate, a.modby, p.title, v.first_name, v.last_name, v.email from 
            descpub_authorship a join descpub_publication p on a.paperid = p.paperid  join profile_user v on v.memidnum = a.memidnum and v.experiment = 'LSST-DESC'
            order by auth_request_date
        </sql:query>
         
        <c:choose>
            <c:when test="${empty param}">
                <h2 id="pagelabel">Requests For Authorship</h2>
                <display:table class="datatable" id="row" name="${docs.rows}" cellspacing="10" cellpadding="10">
                     <display:column property="auth_request_date" title="Request date" style="text-align:right;" sortable="true" headerClass="sortable"/>
                    <display:column property="first_name" title="First name" style="text-align:right;" url="/GroupManager/exp/${appVariables.experiment}/protected/user.jsp?memidnum=${row.memidnum}" sortable="true" headerClass="sortable"/>
                    <display:column property="last_name" title="Last name" style="text-align:right;" url="/GroupManager/exp/${appVariables.experiment}/protected/user.jsp?memidnum=${row.memidnum}" sortable="true" headerClass="sortable"/>
                    <display:column title="Authorship approval" style="text-align:right;" sortable="true" headerClass="sortable">
                        <a href="authorManagement.jsp?paperid=${row.paperid}&memidnum=${row.memidnum}">DESC-${row.paperid}</a>
                    </display:column>
                    <display:column property="reason" title="Reason" style="text-align:right;" sortable="true" headerClass="sortable"/>
                </display:table>
            </c:when>
            <c:when test="${!empty param.paperid && !empty param.memidnum && param.responseSubmitted != 'true'}">
                  <h2>Authorship request on DESC-${param.paperid}</h2>

                  <sql:query var="pers"> <%-- get requestor info --%>
                    select first_name, last_name, user_name, email from profile_user where memidnum = ? and experiment = ?
                    <sql:param value="${param.memidnum}"/>
                    <sql:param value="${appVariables.experiment}"/>
                  </sql:query>
         
                  <sql:query var="isMem"> <%-- check if user already on author list, e.g. paper_N --%>
                      select ug.user_id, p.first_name, p.last_name from profile_ug ug join profile_user p on ug.memidnum=p.memidnum
                      where ug.memidnum = ? and ug.group_id = ? and ug.experiment = ?
                      <sql:param value="${param.memidnum}"/>
                      <sql:param value="paper_${param.paperid}"/>
                      <sql:param value="${appVariables.experiment}"/>
                  </sql:query> 
                  
                  <c:choose>
                      <c:when test="${isMem.rowCount > 0}">
                          <h3>${pers.rows[0].first_name} ${pers.rows[0].last_name} is already an author on DESC-${param.paperid}</h3>
                      </c:when>
                      <c:when test="${isMem.rowCount < 1}">
                         <form action="authorManagement.jsp?paperid=${param.paperid}&memidnum=${param.memidnum}" method="post">
                            <input type="hidden" name="responseSubmitted" value="true"/>
                            <table class="datatable">
                                <utils:trEvenOdd reset="true"><th>Requestor's first name</th><td><input type="text" name="fname" value="${pers.rows[0].first_name}" size="100" style="text-align:right;"/></td>
                                </utils:trEvenOdd>

                                <utils:trEvenOdd><th>Requestor's last name</th><td><input type="text" name="lname" value="${pers.rows[0].last_name}" size="100" style="text-align:right;"/></td>
                                </utils:trEvenOdd>

                                <utils:trEvenOdd><th>Requestor's email</th><td><input type="text" name="Email" value="${pers.rows[0].email}" size="100" style="text-align:right;"/></td>
                                </utils:trEvenOdd>

                               <c:forEach var="col" items="${docs.rows}">
                                   <utils:trEvenOdd><th>Date requested</th><td><input type="text" name="auth_request_date" value="${col.auth_request_date}" size="100" style="text-align:right;"/></td></utils:trEvenOdd>
                                   <utils:trEvenOdd><th>Title</th><td>DESC-${col.title}</td></utils:trEvenOdd>
                                   <utils:trEvenOdd><th>Contribution statement</th><td><input type="text" name="contribution_text" value="${col.contribution_text}" size="100" style="text-align:right;" /></td></utils:trEvenOdd>
                                   <utils:trEvenOdd><th>Check list of contributions</th><td><input type="text" name="contribution_list" value="${col.contribution_list}" size="100" style="text-align:right;"/></td></utils:trEvenOdd>
                                   <utils:trEvenOdd><th>Reason</th><td><input type="text" name="reason" value="DESC-${col.reason}" size="100" style="text-align:right;"/></td></utils:trEvenOdd>
                                   <utils:trEvenOdd><th>Authorship list position</th><td><input type="text" name="auth_pos" value="${col.auth_pos}" size="100" style="text-align:right;"/></td></utils:trEvenOdd>
                                   <utils:trEvenOdd><th>Response to email to the requestor (limit 4000 chars)</th><td><textarea name="response" rows="20" cols="100" maxlength="4000" required></textarea></td></utils:trEvenOdd>
                               </c:forEach> 

                                <utils:trEvenOdd><th>CHOOSE ONE</th><td>              
                                    <select name="request_status" ${required}>
                                        <option value="approved">Request approved</option>
                                        <option value="denied" selected>Request denied</option>
                                        <option value="pending">Request pending</option>
                                    </select></td>                         
                                </utils:trEvenOdd>
                                <utils:trEvenOdd><th>SUBMIT THE FORM</th><td><input type="submit" name="submit" value="submit"/></td></utils:trEvenOdd>
                            </table>
                         </form>
                      </c:when>
                  </c:choose> 
            </c:when>
            <c:when test="${param.responseSubmitted == 'true'}">
                <c:set var="msgbody" value="${param.response}"/>
                <sql:query var="rid">
                    select user_name, first_name, last_name, email from profile_user where memidnum = ? and experiment = ?
                    <sql:param value="${param.memidnum}"/>
                    <sql:param value="${appVariables.experiment}"/>
                </sql:query>   
                    
                
                   
                <c:catch var="trapError">
                    <sql:transaction>
                        <sql:update>
                           insert into profile_ug (user_id, group_id, experiment, memidnum) values (?,?,?,?)
                           <sql:param value="${rid.rows[0].user_name}"/>
                           <sql:param value="paper_${param.paperid}"/>
                           <sql:param value="${appVariables.experiment}"/>
                           <sql:param value="${param.memidnum}"/>
                        </sql:update>

                        <sql:update var="upd">
                            update descpub_authorship set request_status = ?, approved_by = ?, approval_date = sysdate where paperid = ? and memidnum = ?
                            <sql:param value="${param.request_status}"/>
                            <sql:param value="${userName}"/> 
                            <sql:param value="${param.paperid}"/>
                            <sql:param value="${param.memidnum}"/>
                        </sql:update>

                        <%-- mailbody goes first and gets the sequence--%>
                        <sql:update>
                            insert into descpub_mailbody (msgid, subject, body, mail_originator, askdate) values(DESCPUB_MAIL_SEQ.nextval, ?, ?, ?,sysdate)
                            <sql:param value="Response to authorship request for DESC-${param.paperid}"/>
                            <sql:param value="${msgbody}"/>
                            <sql:param value="${memidnum}"/>
                         </sql:update> 

                        <sql:update>
                            insert into descpub_mail_recipient (groupname_or_emailaddr, msgid) values(?,DESCPUB_MAIL_SEQ.currval) 
                            <sql:param value="${rid.rows[0].email}"/>
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