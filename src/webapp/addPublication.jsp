<%-- 
    Document   : addPublication
    Created on : Aug 3, 2017, 1:38:15 PM
    Author     : chee
--%>

<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <script src="../js/jquery-1.11.1.min.js"></script>
        <script src="../js/jquery.validate.min.js"></script>
        <link rel="stylesheet" type="text/css" href="css/pubstyles.css">
        <title>Add Document Page</title>
    </head>
    <body>

    <c:set var="debugMode" value="false"/>
    <%--
    <c:forEach var="x" items="${param}">
        <c:out value="${x.key} = ${x.value}"/><br/>
    </c:forEach> --%>
    
    <c:choose>
        <c:when test="${empty param.formsubmitted}">
                <sql:query var="projInfo">
                   select p.id, p.title, s.name from descpub_project p join descpub_project_swgs j on p.id=j.project_id
                   join descpub_swg s on s.id=j.swg_id  where p.id = ? and s.id = ?
                   <sql:param value="${param.projid}"/>
                   <sql:param value="${param.swgid}"/>
                </sql:query>

                <sql:query var="poolOfCandidates">
                    select m.firstname, m.lastname, m.memidnum, u.username from um_member m join um_project_members p on m.memidnum=p.memidnum
                    join um_member_username u on u.memidnum=m.memidnum where p.activestatus = 'Y' and p.project = ? and m.lastname != 'lsstdesc-user' 
                    order by lower(m.lastname)
                    <sql:param value="${appVariables.experiment}"/>
                </sql:query>

                <sql:query var="pubtypes">
                    select pubtype from descpub_pubtypes order by pubtype
                </sql:query>

                <sql:query var="pubstates">
                    select state_id, state from descpub_publication_states order by state
                </sql:query>

                <div class="intro">
                    <p id="pagelabel">Document Details</p>
                    <strong>Project id [ ${projInfo.rows[0].id} ] ${projInfo.rows[0].title}. <br/> Working group(s): ${projInfo.rows[0].name}</strong>
                </div>
                <p/>
                <form action="addPublication.jsp" method="post">  
                    <input type="hidden" name="projid" id="projid" value="${param.projid}"/> 
                    <input type="hidden" name="swgid" id="swgid" value="${param.swgid}"/>
                    <input type="hidden" name="wgname" id="wgname" value="${param.name}"/> 
                    <input type="hidden" name="formsubmitted" value="true"/>
                    Title: <br/> <input type="text" name="title" id="title" size="80" required/>  
                    <p/>
                     
                    Builder Eligible:<br/>
                    <select name="builder" required>
                       <option value=""></option>
                       <option value="N">No</option>
                       <option value="Y">Yes</option>
                    </select>
                    <p/>
                    Key Paper:<br/>
                    <select name="keypaper" required>
                       <option value=""></option>
                       <option value="N">No</option>
                       <option value="Y">Yes</option>
                    </select>  
                    
                    <p/>
                    Select Lead Author(s):<br/>
                    <select name="authcontacts" multiple size="10" required>
                    <c:forEach var="auth" items="${poolOfCandidates.rows}">
                        <option value="${auth.memidnum}:${auth.firstname} ${auth.lastname}:${auth.username}">${auth.lastname},  ${auth.firstname} </option>
                    </c:forEach>
                    </select>
                    <p/>
                    Type:<br/> 
                    <select name="pubtyp">
                    <c:forEach var="ptype" items="${pubtypes.rows}">
                        <option value="${ptype.pubtype}">${ptype.pubtype}</option>
                    </c:forEach>
                    </select> 
                    <p/>

                    State:<br/> 
                    <select name="pubstate">
                    <c:forEach var="stype" items="${pubstates.rows}">
                        <option value="${stype.state}">${stype.state}</option>
                    </c:forEach>
                    </select> 
                    <p/>
                    <input type="submit" value="Create Document Entry" name="addPub" />  
                </form>
                <p/>
                <hr align="left" width="50%"/>
                <p/>
                <p id="pagelabel">Upload Document</p>

                <form action="uploadPub.jsp" method="post" enctype="multipart/form-data">
                    <input type="file" name="fileToUpload" id="fileToUpload">
                    <input type="submit" value="Upload Document" name="submit">
                  <%--  <input type="hidden" name="forwardTo" value="/uploadTest.jsp" /> --%>
                    <input type="hidden" name="forwardTo" value="/uploadPub.jsp" />
                </form>  
        </c:when>
        <c:when test="${param.formsubmitted}">
          <%--
            <c:forEach var="x" items="${param}">
                <c:out value="${x.key} = ${x.value}"/><br/>
                <c:if test = "${x.key  == 'authcontacts'}">
                    <c:forEach var="y" items="${paramValues[x.key]}">
                        <c:set var="array" value="${fn:split(y,':')}"/>
                        <c:out value="ContactAuth: ${array[0]}, ${array[1]}, ${array[2]}"/><br/>
                    </c:forEach>
                </c:if>
            </c:forEach>  --%>
                        
        <c:catch var="trapError"> 
            <sql:transaction>
            <sql:update >
                insert into descpub_publication (paperid, title, state, added, builder_eligible, keypub, project_id, pubtype) values(DESCPUB_PUB_SEQ.nextval,?,?,sysdate,?,?,?,?)
                <sql:param value="${param.title}"/>
                <sql:param value="${param.pubstate}"/>
                <sql:param value="${param.builder}"/>
                <sql:param value="${param.keypaper}"/>
                <sql:param value="${param.projid}"/>
                <sql:param value="${param.pubtyp}"/>
            </sql:update>  

            <sql:query var="curr">
                select DESCPUB_PUB_SEQ.currval as currval from dual
            </sql:query>
                  
            <c:set var="current" value="${curr.rows[0].currval}"/>
            <c:set var="group_name" value="paper_${current}"/> 
            <c:set var="leadauthgrp" value="paper_leads_${current}"/>
            <c:set var="grpmanager" value="lsst-desc-publication-admins"/>
            
            <%-- insert paper group into profile_group, paper lead group is the managing group --%> 
            <sql:update>
                insert into profile_group (group_name,group_manager,experiment) values (?, ?, ?)
                <sql:param value="${group_name}"/>
                <sql:param value="${leadauthgrp}"/>
                <sql:param value="${appVariables.experiment}"/>
            </sql:update> 
                
            <%-- insert paper lead group into profile_group, lsst-desc-publication-admins is the managing group --%> 
            <sql:update>
                insert into profile_group (group_name,group_manager,experiment) values (?, ?, ?)
                <sql:param value="${leadauthgrp}"/>
                <sql:param value="${grpmanager}"/>
                <sql:param value="${appVariables.experiment}"/>
            </sql:update> 
            
            <%-- add lead authors to the paper lead group --%>
            <c:forEach var="con" items="${paramValues['authcontacts']}">
                <c:set var="array" value="${fn:split(con,':')}"/>
                <sql:update>
                    insert into profile_ug (user_id, group_id, experiment, memidnum) values(?,?,?,?)
                    <sql:param value="${array[2]}"/>
                    <sql:param value="${leadauthgrp}"/>
                    <sql:param value="${appVariables.experiment}"/>
                    <sql:param value="${array[0]}"/>
                </sql:update> 
            </c:forEach>
            </sql:transaction>
        </c:catch>
       
        <c:if test="${trapError != null}">
            <h1>Error. Failed to create document: ${param.title}<br/>
                ${trapError}
            </h1>
        </c:if>
        <c:if test="${trapError != null}">
          <c:redirect url="show_project.jsp?projid=${param.projid}&swgid=${param.swgid}"/>   
        </c:if>
       </c:when>
    </c:choose>
    </body>
</html>
