<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Authorship Request</title>
        <script src="js/jquery-1.11.1.min.js"></script>
        <script src="js/jquery.validate.min.js"></script>
        <link rel="stylesheet" href="css/pubstyles.css">
    </head>
    <body>
    
         <tg:underConstruction/>
    <%--
    <c:forEach var="x" items="${param}">
        <c:out value="${x.key} = ${x.value}"/><br/>
    </c:forEach>  --%>
    
    <c:choose>
        <c:when test="${!empty param.reason}">
            <sql:query var="currnum">
                select (max(b.id) + 1) newnum from descpub_mail_recipient a join descpub_mailbody b on a.id=b.id and a.groupname = ?
                <sql:param value="paper_leads_${param.paperid}"/>
            </sql:query>
            
            <sql:transaction>
                <sql:query var="recips">
                   select p.first_name, p.last_name, p.email from profile_user p join profile_ug ug on p.memidnum = ug.memidnum and p.experiment=ug.experiment
                   where ug.group_id = ? and ug.experiment = ?
                   <sql:param value="paper_leads_${param.paperid}"/>
                   <sql:param value="${appVariables.experiment}"/>
                </sql:query>
          
                <sql:update>
                     insert into descpub_mail_recipient (id, groupname) values(?,?)
                     <sql:param value="${newnum}"/>
                     <sql:param value="paper_leads_${param.paperid}"/>
                </sql:update>
                      
                 <sql:update>
                     insert into descpub_mailbody (id, subject, body, requestor, askdate) values(?, ?, ?, ?,sysdate)
                     <sql:param value="${newnum}"/>
                     <sql:param value="DESCPUB Authorship Request For Document ${param.paperid}"/>
                     <sql:param value="${param.reason}"/>
                     <sql:param value="${userName}"/>
                 </sql:update>
            </sql:transaction>  
            
            <c:if test="${empty catchError}">
                <p id="pagelabel"> Your request for authorship has been sent to:</p>
                <display:table class="datatable" name="${recips.rows}" id="Rows"/>
                <c:forEach var="x" items="${recips.rows}">
                    <c:out value="${x.first_name} ${x.last_name} at ${x.email}"/><br/>
                </c:forEach>  
           </c:if>  
           <c:if test="${!empty catchError}">
                <p id="pagelabel"> Authorship request failed. Reaons: ${catchError}</p>   
           </c:if>  
        </c:when>
        <c:when test="${!empty param.paperid}">
            <p id="pagelabel">Request Authorship for document ${param.paperid}</p>
            <form action="requestAuthorship.jsp?paperid=${param.paperid}">
                <input type="hidden" value="${param.paperid}" name="paperid"/><br/>
                <p id="pagelabel">Reason</p>
                <textarea name="reason" rows="5" cols="150" required></textarea><p/>
                <input type="submit" value="Send_Request" name="submit"/>    
            </form>
        </c:when>
    </c:choose>
    </body>
</html>

