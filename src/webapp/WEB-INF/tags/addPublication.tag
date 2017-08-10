<%-- 
    Document   : addPublication
    Created on : Aug 3, 2017, 1:22:25 PM
    Author     : chee
--%>

<%@tag description="add publication to project" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%-- The list of normal or fragment attributes can be specified here: --%>
<%@attribute name="projid" required="true"%>
<%@attribute name="experiment" required="true"%>
<%@attribute name="returnURL" required="true" %>

<script src="js/jquery-1.11.1.min.js"></script>
<script src="js/jquery.validate.min.js"></script>
    
<form action="addPublication.jsp">  
    <input type="hidden" name="projid" id="projid" value="${projid}" /> 
    <input type="hidden" name="redirectTo" value="${returnURL}"/> 
    <table border="0">
        <thead>
            <tr>
                <th>Add Publication</th>
            </tr>
        </thead>
        <tbody>
            <tr><td>Title: <input type="text" name="title" id="title" size="200" required/><td/></tr>
            <tr><td><input type="submit" value="Add" name="action" /></td></tr>
        </tbody>
    </table>
</form>