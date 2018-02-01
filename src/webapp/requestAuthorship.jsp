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
        
    <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>
        
    <tg:underConstruction/>
    
    Link to <a href="">Authorship Guide</a> [pdf]<br/>  
    
    <sql:query var="contribs">
        select initcap(label) label from descpub_contributions order by label
    </sql:query>
    
    <c:choose>
        <c:when test="${!empty param.reason}">
            <%-- add chosen contributions to mail msg --%>
            <c:set var="contributions" value=""/>
            <c:forEach var="x" items="${param}" varStatus="loop">
                <c:if test="${x.key == 'label'}">
                    <c:forEach var="pv" items="${paramValues[x.key]}">
                        <c:choose>
                        <c:when test="${empty contributions}">
                            <c:set var="contributions" value="${pv}"/>
                        </c:when>
                        <c:when test="${!empty contributions}">
                            <c:set var="contributions" value="${contributions}, ${pv}"/> 
                        </c:when>
                        </c:choose>
                    </c:forEach>
                </c:if>
            </c:forEach>
            
            <c:set var="msgbody" value="REASON: ${param.reason}  SELECTED CONTRIBUTIONS: ${contributions}"/>
            <sql:transaction>
                <sql:query var="recips">
                   select p.first_name, p.last_name, p.email from profile_user p join profile_ug ug on p.memidnum = ug.memidnum and p.experiment=ug.experiment
                   where ug.group_id = ? and ug.experiment = ?
                   <sql:param value="paper_leads_${param.paperid}"/>
                   <sql:param value="${appVariables.experiment}"/>
                </sql:query>
                     
                <sql:update>
                     insert into descpub_mailbody (msgid, subject, body, mail_originator, askdate) values(DESCPUB_MAIL_SEQ.nextval, ?, ?, ?,sysdate)
                     <sql:param value="DESCPUB Authorship Request For DESC-${param.paperid}"/>
                     <sql:param value="${msgbody}"/>
                     <sql:param value="${userName}"/>
                 </sql:update>  
                     
                 <sql:update>
                     insert into descpub_mail_recipient (msgid, groupname_or_emailaddr) values(DESCPUB_MAIL_SEQ.currval,?)
                     <sql:param value="paper_leads_${param.paperid}"/>
                </sql:update>
            </sql:transaction>  
            
            <c:if test="${empty catchError}">
                <p id="pagelabel"> Thank you. Your request for authorship has been sent to:</p>
                <display:table class="datatable" name="${recips.rows}" id="Rows">
                    <display:column title="FirstName">
                        ${Rows.first_name}
                    </display:column>
                    <display:column title="LastName">
                        ${Rows.last_name}
                    </display:column>
                    <display:column title="LastName">
                        ${Rows.email}
                    </display:column>
                </display:table>
           </c:if>  
           <c:if test="${!empty catchError}">
                <p id="pagelabel"> Authorship request failed. Reason: ${catchError}</p>   
           </c:if>   
        </c:when>
        <c:when test="${!empty param.paperid}">
            <p id="pagelabel">Request Authorship for DESC-${param.paperid}. <br/>Please enter your reason for authorship</p>
            <form action="requestAuthorship.jsp?paperid=${param.paperid}">
                <input type="hidden" value="${param.paperid}" name="paperid"/><br/>
              <%--  <p id="pagelabel">Reason for authorship</p> --%>
                <textarea name="reason" rows="5" cols="150" required></textarea><p/>
                <p id="pagelabel">Contribution(s) - check all that apply<br/>
                    Refer to authorship guide, section 3, for more detailed explanation
                </p>
                <c:forEach var="c" items="${contribs.rows}">
                 ${c['name']}  <input type="checkbox" name="name" value="${c['name']}"/><br/>
                </c:forEach>
                <p></p>
                <input type="submit" value="Send_Request" name="submit"/>    
            </form>
        </c:when>
    </c:choose>
    </body>
</html>

