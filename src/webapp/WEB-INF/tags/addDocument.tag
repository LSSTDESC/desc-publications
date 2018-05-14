<%-- 
    Document   : addDocument
    Created on : Aug 14, 2017, 2:14:37 PM
    Author     : chee
--%>

<%@tag description="add publication to project" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%-- The list of normal or fragment attributes can be specified here: --%>
<%@attribute name="projid" required="true"%>
<%@attribute name="swgid" required="true"%>
<%@attribute name="userName" required="true"%>
<%@attribute name="experiment" required="true"%>
<%@attribute name="returnURL" required="true" %>

<script src="js/jquery-1.11.1.min.js"></script>
<script src="js/jquery.validate.min.js"></script>

<sql:query var="getid" dataSource="jdbc/config-dev">
     select memidnum, first_name, last_name from profile_user where experiment = ? and user_name = ? and active = 'Y'
     <sql:param value="${appVariables.experiment}"/>
     <sql:param value="${userName}"/>
</sql:query>
     

    
     <c:choose>
     <c:when test="${getid.rowCount > 0}">
         
<form action="addDocument.jsp">  
    <input type="hidden" name="projid" id="projid" value="${projid}" /> 
    <input type="hidden" name="memidnum" id="memidnum" value="${getid.rows[0].memidnum}" /> 
    <input type="hidden" name="swgid" id="swgid" value="${swgid}" /> 
    <input type="hidden" name="fname" id="fname" value="${getid.rows[0].first_name}" /> 
    <input type="hidden" name="lname" id="lname" value="${getid.rows[0].last_name}" /> 
    <input type="hidden" name="redirectTo" value="${returnURL}"/> 
   
    <table border="0">
        <thead>
            <tr>
                <th>Add Document</th>
            </tr>
        </thead>
        <tbody>
            <tr><td>Title: <input type="text" name="title" id="title" size="80" required/><td/></tr>
            <tr><td>DocType: <input type="text" name="doctype" id="title" size="80" required/><td/></tr>
            <tr><td><input type="submit" value="AddDoc" name="action" /></td></tr>
        </tbody>
    </table>  
</form>
     </c:when>
         <c:otherwise>
             <c:redirect url="noPermission.jsp?errmsg=3"/>
         </c:otherwise>
     </c:choose>