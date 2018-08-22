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
        <script src="js/checkAuthRequest.js"></script>
        <link rel="stylesheet" href="css/pubstyles.css">
    </head>
    <body>
        
        
    <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>  
        
    <sql:query var="userInfo">
        select m.firstname, m.lastname, u.email, m.memidnum from um_member m join um_member_username u on m.memidnum=u.memidnum join profile_user u on u.memidnum=m.memidnum
        where u.username = ? and u.active = 'Y'
        <sql:param value="${userName}"/>
    </sql:query> 
    <c:if test="${userInfo.rowCount < 1}">
       <c:redirect url="noPermission.jsp?errmsg=9"/>
    </c:if> 
    <c:set var="fname" value="${userInfo.rows[0].firstname}"/>
    <c:set var="lname" value="${userInfo.rows[0].lastname}"/>
    <c:set var="requestfrom" value="${userInfo.rows[0].email}"/>
    <c:set var="memidnum" value="${userInfo.rows[0].memidnum}"/>
    
    <tg:underConstruction/>
    
    Link to <a href="https://github.com/LSSTDESC/Author_Guide/raw/compiled/Author_Guide.pdf">Authorship Guide</a> [pdf] (requires github login)<br/>  
     
    <c:set var="debugMode" value="false"/>
    
    <%-- get list of possible contributions --%>
    <sql:query var="contribs">
        select initcap(label) label from descpub_contributions order by label
    </sql:query>
    
    <sql:query var="t">
       select title from descpub_publication where paperid = ?
       <sql:param value="${param.paperid}"/>
    </sql:query>
       
    <c:set var="title" value="${t.rows[0].title}"/>
    
   <%-- build the contributions list --%>
    <c:forEach var="x" items="${param}" varStatus="loop">
        <c:if test="${x.key =='cname'}">
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
    
    <%-- build the recipient list --%>
    <c:choose>
        <c:when test="${debugMode == 'false'}">
            <sql:query var="recips">
            select p.first_name, p.last_name, p.email from profile_user p join profile_ug ug on p.memidnum = ug.memidnum and p.experiment=ug.experiment and p.active = 'Y'
            where ug.group_id = ? and ug.experiment = ?
            <sql:param value="paper_leads_${param.paperid}"/>
            <sql:param value="${appVariables.experiment}"/>
            </sql:query>
            
            <c:forEach var="re" items="${recips.rows}">
                <c:choose>
                    <c:when test="${empty recipList}">
                        <c:set var="recipList" value="${re.email}"/>
                    </c:when>
                    <c:when test="${! empty recipList}">
                        <c:set var="recipList" value="${recipList},${re.email}"/>
                    </c:when>
                </c:choose>
            </c:forEach>
            
            <p id="pagelabel">Your request will go to ${recips}.</p> 
        </c:when>
        <c:when test="${debugMode=='true'}">
            <c:set var="recips" value="chee@slac.stanford.edu"/>
            <p id="pagelabel">Your request will go to the lead author(s) ${recips}.</p>
        </c:when>
    </c:choose> 
                   
    <c:choose>
        <c:when test="${!empty param.reason && debugMode == 'true'}">
          <%--  <c:set var="msgbody" value="From: ${requestfrom} Reason: ${param.reason}  Selected Contributions: ${contributions}"/> --%>
          
            <c:set var="msgbody" value="
            Dear Primary Authors,%0D%0A

${fname} ${lname} is asking to be considered as a co-author of your publication DESC-${param.paperid}. You can read their justification below. %0D%0A
When you have converged on a good response, please reply to them via the publication mgmt system at this link, and update the author list as %0D%0A
required. For guidance on authorship criteria, please consult the LSST DESC publication policy, and if in doubt, please don't hesitate to contact%0D%0A
the LSST DESC pub board (cc on this email).%0D%0A

Thanks!%0D%0A

The DESC Publication Management System%0D%0A

${fname} ${lname} writes: %0D%0A
Reason for co-authorship: ${param.reason} %0D%0A
Proposed contribution statement: ${param.contribution_stmt} %0D%0A
Checklist contributions: ${contributions} %0D%0A
"/>
          
            <p>insert into descpub_mailbody values ('sequence', ${param.paperid}, ${msgbody}, ${userName})</p>
            <p>msgbody: ${msgbody}</p>
            <p>${param.reason}</p>
            <p>${param.contribution_stmt}</p>
            <p>From: ${requestfrom}</p>
            <p>Memidnum: ${memidnum}</p>
            <p>userName: ${userName}</p>

          
            

        </c:when>
        <c:when test="${!empty param.reason && debugMode != 'true'}">
            <%-- add chosen contributions to mail msg --%>
          <%--  <c:set var="msgbody" value="From: ${requestfrom} Reason: ${param.reason}  Selected Contributions: ${contributions}"/> --%>
            <c:set var="msgbody" value="Dear Primary Authors,%0D%0A
${fname} ${lname} is asking to be considered as a co-author of your publication DESC-${param.paperid}. You can read their justification below. %0D%0A
When you have converged on a good response, please reply to them via the publication mgmt system at this link, and update the author list as %0D%0A
required. For guidance on authorship criteria, please consult the LSST DESC publication policy, and if in doubt, please don't hesitate to contact%0D%0A
the LSST DESC pub board (cc on this email).%0D%0A

Thanks!%0D%0A

The DESC Publication Management System%0D%0A

${fname} ${lname} writes: %0D%0A
Reason for co-authorship: ${param.reason} %0D%0A
Proposed contribution statement: ${param.contribution_stmt} %0D%0A
Checklist contributions: ${contributions} %0D%0A
"/>
            
            <sql:transaction>
                <sql:update>
                     insert into descpub_mailbody (msgid, subject, body, mail_originator, askdate) values(DESCPUB_MAIL_SEQ.nextval, ?, ?, ?,sysdate)
                     <sql:param value="Request for authorship on ${title}, DESC-${param.paperid} "/>
                     <sql:param value="${msgbody}"/>
                     <sql:param value="${memidnum}"/>
                 </sql:update>  
                <sql:update>
                     insert into descpub_mail_recipient (msgid, groupname_or_emailaddr) values(DESCPUB_MAIL_SEQ.currval,?)
                     <sql:param value="TESTLIST"/>
                </sql:update>
            </sql:transaction> 
           
            <c:if test="${empty catchError}">
                <p id="pagelabel"> Thank you. Your request for authorship has been sent to:</p>
                <display:table class="datatable" name="${recips.rows}" id="Rows">
                    <display:column title="FirstName" property="first_name" style="text-align:left;"/>
                    <display:column title="LastName" property="last_name" style="text-align:left;"/>
                    <display:column title="Email" property="email" style="text-align:left;"/>
                </display:table>
           </c:if>  
           <c:if test="${!empty catchError}">
                <p id="pagelabel"> Authorship request failed. Reason: ${catchError}</p>   
           </c:if>  
 
        </c:when>
        <c:when test="${!empty param.paperid}">
            <p id="pagelabel">Request Authorship for DESC-${param.paperid}. &nbsp;&nbsp;Please state your reason for this request.</p>
            <form action="requestAuthorship.jsp?paperid=${param.paperid}" name="requestAuth" id="requestAuth" method="post">
                <input type="hidden" value="${param.paperid}" name="paperid"/>
                <p><textarea name="reason" rows="15" cols="80" required></textarea></p>
                
                <p id="pagelabel">Contribution(s) - check all that apply<br/>
                    Refer to authorship guide, section 3, for more detailed explanation
                </p>
                <c:forEach var="c" items="${contribs.rows}">
                     <input type="checkbox" class="checkbox" name="cname" value="${c['label']}"/>${c['label']} <br/>
                </c:forEach>
                <p></p>
                 <p id="pagelabel">Please enter a brief statement of your contribution to the paper. If you are <br/> accepted as an author of the paper, this statement will be made publicly <br/> available in 
                    an online database of DESC author contributions. <br/>If the primary authors edit your statement, e.g., for uniformity, they will notify you.</p>
                 <p>
                    <textarea name="contribution_stmt" rows="15" cols="80" required></textarea>
                 <p/>
                 
                <input type="submit" value="Send_Request" name="submit"/>    
            </form>
            <script> 
            $("#requestAuth").validate({
                errorPlacement: function(error,element){
                    element.val(error.text());
                }
                errorClass: "my-error-class"
            }); 
           </script>   
        </c:when>
    </c:choose>
    </body>
</html>

