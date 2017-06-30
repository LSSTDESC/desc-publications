<%@page trimDirectiveWhitespaces="true"%>
<%@page contentType="text/csv" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%response.setHeader("Content-Disposition", "attachment; filename=votes.csv");%>
<c:set var="newline" value="
"/>
<c:if test="${gm:isUserInGroup(pageContext,'VotingAdmin')}">
<sql:query var="candidates">
    select name,key from lsstdesc_voting_candidates order by name
</sql:query>
<c:set var="keys" value=""/>Vote_id,<c:forEach var="c" items="${candidates.rows}" varStatus="status">${c.name}${status.last?"":","}<c:set var="keys" value="${keys}${c.key}${status.last?'':','}"/></c:forEach>
<sql:query var="votes">
    select * from lsstdesc_voting_vote pivot (
    max(ranking) for (candidate_key) in (${keys})
    )            
</sql:query>
<c:forEach var="v" items="${votes.rows}">
    ${newline}${v.vote_id},<c:forEach var="c" items="${candidates.rows}" varStatus="status">${v[c.key.toString()]}${status.last?"":","}</c:forEach>
</c:forEach>
</c:if>