<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%@attribute name="groupname" required="true"%>
<%@attribute name="candidategroup" required="false" %>
<%@attribute name="returnURL" required="true" %>
 

<c:if test="${empty candidategroup}">
    <c:set var="candidategroup" value="lsst-desc-members"/>
</c:if>

<sql:query var="candidates">
    with tmp_names as (
    select me.memidnum, me.firstname, me.lastname, mu.username from um_member me join um_member_username mu on me.memidnum=mu.memidnum
    join um_project_members pm on me.memidnum=pm.memidnum 
    join profile_ug ug on ug.memidnum=pm.memidnum and ug.group_id = ? where pm.activestatus='Y' and pm.project = ? and me.lastname != 'lsstdesc-user'
    minus       
    select me.memidnum, me.firstname, me.lastname, mu.username from um_member me join um_member_username mu on me.memidnum=mu.memidnum
    join profile_ug ug on me.memidnum=ug.memidnum where group_id = ? and me.lastname != 'lsstdesc-user' ) select * from tmp_names order by lower(lastname)
    <sql:param value="${candidategroup}"/>
    <sql:param value="${appVariables.experiment}"/>
    <sql:param value="${groupname}"/>
</sql:query>

<sql:query var="members">
    select me.memidnum, me.firstname, me.lastname, mu.username from um_member me join um_member_username mu on me.memidnum=mu.memidnum
    join profile_ug ug on me.memidnum=ug.memidnum where group_id = ? order by me.lastname
    <sql:param value="${groupname}"/>
</sql:query>
     
<form action="modifyGroupMembers.jsp" method="post">  
    <input type="hidden" name="groupname" value="${groupname}"/> 
    <input type="hidden" name="candidategroup" value="${candidategroup}"/> 
  <%--  <input type="hidden" name="redirectTo" value="${returnURL}"/> --%>
    <input type="hidden" name="returnURL" value="${returnURL}"/> 
    <table border="0">
        <tbody>
            <tr>
                <td><input type="submit" value="Join" name="action" /></td>
                <td><input type="submit" value="Leave" name="action" /></td>
            </tr>
            <tr>
                <td><select name="addMember" size="8" multiple>
                        <c:forEach var="addrow" items="${candidates.rows}">
                            <option value="${addrow.memidnum}:${addrow.username}">${addrow.firstname} ${addrow.lastname}</option>
                        </c:forEach>
                    </select></td>
                <td><select name="removeMember" size="8" multiple>
                        <c:forEach var="remrow" items="${members.rows}"> 
                            <option value="${remrow.memidnum}:${remrow.username}">${remrow.firstname} ${remrow.lastname}</option>
                        </c:forEach>
                    </select></td>
            </tr>
        </tbody>
    </table>

    <p/>
</form>
  