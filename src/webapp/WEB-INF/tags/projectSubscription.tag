<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%@attribute name="groupname" required="true"%>
<%@attribute name="memidnum" required="true"%>
<%@attribute name="userid" required="true"%>
<%@attribute name="returnURL" required="true"%>

<form action="subscribeProject.jsp?group_id=${groupname}" memidnum="${memidnum}" method="post">   
   <select id="grpsubscribe" name="grpsubscribe">
       <option value=""></option>
       <option value="join">Join this project</option>
       <option value="leave">Leave this project</option>
   </select>
   <input type="hidden" name="groupname" value="${groupname}"/>
   <input type="hidden" name="memidnum" value="${memidnum}"/>
   <input type="hidden" name="userid" value="${userid}"/> 
   <input type="hidden" name="returnURL" value="${returnURL}"/> 
   <input type="submit" value="submit" name="action" />
</form>
     