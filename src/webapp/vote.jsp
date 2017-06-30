<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="f" uri="http://lsstdesc.org/functions" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
        <!-- Record the vote -->
        <c:set var="vote_id" value="${f:randomUUID()}"/>
        <sql:transaction>
            <sql:query var="parameters">
                select max_rank,test_mode from lsstdesc_voting_parameters
            </sql:query>
            <c:set var="max_rank" value="${parameters.rows[0]['max_rank']}"/>
            <c:set var="test_mode" value="${parameters.rows[0]['test_mode']=='Y'}"/>
            <sql:query var="previous_vote">
                select to_char(max(time)) last_vote from lsstdesc_voting_record where username=?
                <sql:param value="${userName}"/>
            </sql:query>
            <c:choose>
                <c:when test="${test_mode || empty previous_vote.rows[0].last_vote}">
                    <c:forEach var="p" items="${paramValues['vote']}">
                        <c:set var="rc" value="${fn:split(p,'-')}"/>
                        <c:if test="${rc[0]!='X' && rc[1]!='X'}">
                            <sql:update>
                                insert into lsstdesc_voting_vote(vote_id,candidate_key,ranking) values (?,?,?)
                                <sql:param value="${vote_id.toString()}"/>
                                <sql:param value="${rc[1]}"/>
                                <sql:param value="${rc[0]}"/>                           
                            </sql:update>
                        </c:if>
                    </c:forEach>
                    <sql:update>
                        insert into lsstdesc_voting_record(username,vote_id) values (?,?)
                        <sql:param value="${userName}"/>
                        <sql:param value="${vote_id.toString()}"/>
                    </sql:update>
                </c:when>
                <c:otherwise>
                    <c:set var="reason" value="you already voted on ${previous_vote.rows[0].last_vote}."/>
                </c:otherwise>
            </c:choose>
        </sql:transaction>
        <c:redirect url="recorded.jsp">
            <c:param name="reason" value="${reason}"/>
        </c:redirect>
    </body>
</html>
