<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<%@attribute name="groupname" required="true"%>
<%@attribute name="experiment" required="true"%>
<%@attribute name="candidategroup" required="true" %>    

<sql:query var="candidates" dataSource="jdbc/config-dev">
    select me.memidnum, me.firstname, me.lastname, mu.username from um_member me join um_member_username mu on me.memidnum=mu.memidnum
    join um_project_members pm on me.memidnum=pm.memidnum 
    join profile_ug ug on ug.memidnum=pm.memidnum and ug.group_id = ? where pm.activestatus='Y' and pm.project = ?
    minus       
    select me.memidnum, me.firstname, me.lastname, mu.username from um_member me join um_member_username mu on me.memidnum=mu.memidnum
    join profile_ug ug on me.memidnum=ug.memidnum where group_id = ?
    <sql:param value="${candidategroup}"/>
    <sql:param value="${experiment}"/>
    <sql:param value="${groupname}"/>
</sql:query>

<sql:query var="members" dataSource="jdbc/config-dev">
    select me.memidnum, me.firstname, me.lastname, mu.username from um_member me join um_member_username mu on me.memidnum=mu.memidnum
    join profile_ug ug on me.memidnum=ug.memidnum where group_id = ? order by me.lastname
    <sql:param value="${groupname}"/>
</sql:query>

<form action="modifyGroupMembers.jsp">  
    <input type="hidden" name="swgid" value="${param.swgid}" />  
      
    <table border="0">
        <thead>
            <tr>
                <th>Candidates</th>
                <th>Conveners</th>
            </tr>
        </thead>
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