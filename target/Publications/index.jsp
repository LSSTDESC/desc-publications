<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<html>
    <head>
        <SCRIPT LANGUAGE="JavaScript">


<!-- Begin
            function checkAll(checkbox, field)
            {
                if (!checkbox.checked) {
                    checkbox.checked = true;
                    return;
                }
                var rowChecked = {}, colChecked = {}, atLeastOneChecked = false;
                rc = checkbox.value.split("-");
                r = rc[0];
                c = rc[1];
                for (i = 0; i < field.length; i++) {
                    rc = field[i].value.split("-");
                    if (field[i] !== checkbox) {
                        if ((r === rc[0] && r !== "X") || (c === rc[1] && c !== "X")) {
                            field[i].checked = false;
                        }
                    }
                    if (field[i].checked) {
                        if (rc[0] !== "X" && rc[1] !== "X")
                            atLeastOneChecked = true;
                        if (rc[0] !== "X")
                            rowChecked[rc[0]] = true;
                        if (rc[1] !== "X")
                            colChecked[rc[1]] = true;
                    }
                }
                for (i = 0; i < field.length; i++) {
                    if (field[i] !== checkbox) {
                        rc = field[i].value.split("-");
                        if ((rc[0] === "X") && (!colChecked[rc[1]])) {
                            field[i].checked = true;
                        }
                        if ((rc[1] === "X") && (!rowChecked[rc[0]])) {
                            field[i].checked = true;
                        }
                    }
                }
                document.votes.submit.disabled = !atLeastOneChecked;
            }

//  End -->
        </script>
        <style>
            #votes {
                font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
                width: 100%;
                border-collapse: collapse;
            }

            #votes td, #votes th {
                font-size: 1.1em;
                border: 1px solid #98bf21;
                padding: 3px 7px 2px 7px;
                text-align: left;
            }

            #votes th {
                font-size: 1.1em;
                text-align: center;
                padding-top: 5px;
                padding-bottom: 4px;
                background-color: #A7C942;
                color: #ffffff;
            }

            #votes tr.alt td {
                color: #000000;
                background-color: #EAF2D3;
            }
        </style>
    </head>
    <body>
        <jsp:useBean id="random" class="java.util.Random"/>
        <c:set var="fullMember" value="${gm:isUserInGroup(pageContext,'pubAccess')}"/>
        <c:if test="${fullMember}">
            <sql:query var="parameters">
                select max_rank,test_mode,admin_name,admin_email,no_vote_column_name, no_vote_row_name,
                   to_char(start_time,'dd-mon-yyyy HH24:mi:ss TZR') as start_time,
                   to_char(end_time,'dd-mon-yyyy HH24:mi:ss TZR') as end_time,
                   to_char(current_timestamp,'dd-mon-yyyy HH24:mi:ss TZR') as now,
                   (case when start_time is null or start_time<current_timestamp then 'true' else 'false' end) as started,
                   (case when end_time<current_timestamp then 'true' else 'false' end) as ended
                from lsstdesc_voting_parameters 
            </sql:query>
            <c:set var="max_rank" value="${parameters.rows[0]['max_rank']}"/>
            <c:set var="test_mode" value="${parameters.rows[0]['test_mode']=='Y'}"/>
            <c:set var="admin_name" value="${parameters.rows[0]['admin_name']}"/>
            <c:set var="admin_email" value="${parameters.rows[0]['admin_email']}"/>
            <c:set var="start_time" value="${parameters.rows[0]['start_time']}"/>
            <c:set var="end_time" value="${parameters.rows[0]['end_time']}"/>
            <c:set var="now" value="${parameters.rows[0]['now']}"/>
            <c:set var="started" value="${parameters.rows[0]['started']}"/>
            <c:set var="ended" value="${parameters.rows[0]['ended']}"/>
            <c:set var="no_vote_column_name" value="${parameters.rows[0]['no_vote_column_name']}"/>
            <c:set var="no_vote_row_name" value="${parameters.rows[0]['no_vote_row_name']}"/>
            <sql:query var="previous_vote">
                select to_char(max(time),'dd-mon-yyyy HH24:mi:ss TZR') last_vote from lsstdesc_voting_record where username=?
                <sql:param value="${userName}"/>
            </sql:query>
            <c:if test="${!empty previous_vote.rows[0].last_vote}">
                You already voted on ${previous_vote.rows[0].last_vote}.
                <c:if test="${test_mode}">
                    Normally we would not let you vote again, but since we are in test mode we will.
                </c:if>
            </c:if>
            <c:set var="votingWindowOpen" value="${started and !ended}"/>
            <c:if test="${!started}">
                <p>The voting window is not open yet, voting will start at ${start_time}</p>
            </c:if>
            <c:if test="${ended}">
                <p>The voting window has closed.</p>
            </c:if>
            <c:if test="${test_mode || empty previous_vote.rows[0].last_vote}">
                <sql:query var="candidates">
                    select key,name,institute,url from lsstdesc_voting_candidates order by key asc
                </sql:query>
                <c:set var="offset" value="${random.nextInt(candidates.rowCount)}"/>
                <p>Rank up to ${max_rank} of the ${candidates.rowCount} candidates below with rank 1 corresponding to top choice, rank 2 to second choice, etc . 
                    Candidates are listed alphabetically but with a random starting point to avoid position bias.</p> 
                <form name="votes" method="POST" action="vote.jsp">
                    <table id="votes">
                        <tr>
                            <th rowspan="2">Candidate</th>
                            <th rowspan="2">Institution</th>
                            <th colspan="${max_rank+1}">Rank</th>
                        </tr>
                        <tr>
                            <c:forEach var="r" begin="1" end="${max_rank}">
                                <th>${r}</th>
                                </c:forEach>
                            <c:if test="${!empty no_vote_row_name}">
                               <th>${no_vote_row_name}</th>
                            </c:if>
                        </tr>
                        <c:forEach var="c" begin="0" end="${candidates.rowCount-1}">
                            <c:set var="candidate" value="${candidates.rows[(c+offset) % candidates.rowCount]}"/>
                            <tr ${c%2==0?'class="alt"':''}>
                                <td>
                                    <c:if test="${!empty candidate.url}">
                                        <a href="${candidate.url}" target="VotingCandidate">
                                    </c:if>
                                    ${candidate.name}
                                    <c:if test="${!empty candidate.url}">
                                        </a>
                                    </c:if>
                                </td>
                                <td>
                                    ${candidate.institute}
                                </td>
                                <c:forEach var="r" begin="1" end="${max_rank}">
                                    <td><input type="checkbox" name="vote" value="${r}-${candidate.key}" onClick="checkAll(this, document.votes.vote)"></td>
                                </c:forEach>
                                <c:if test="${!empty no_vote_row_name}">
                                    <td><input type="checkbox" name="vote" value="X-${candidate.key}" onClick="checkAll(this, document.votes.vote)" checked></td>
                                </c:if>
                            </tr>
                        </c:forEach>
                        <c:if test="${!empty no_vote_column_name}">
                            <tr>
                                <th colspan="2">${no_vote_column_name}</th>
                                    <c:forEach var="r" begin="1" end="${max_rank}">
                                    <td><input type="checkbox" name="vote" value="${r}-X" onClick="checkAll(this, document.votes.vote)" checked></td>
                                    </c:forEach>
                            </tr>
                        </c:if>
                    </table>
                    <c:if test="${votingWindowOpen}">
                        <p><b>Note:</b> Your vote will be recorded when you push the button below. Since we record the votes and voters but not the 
                        relationship between the votes and voters, once recorded your vote cannot be changed.</p>
                       <input type="reset" value="Clear Vote" onClick="checkAll(this, document.votes.vote)">
                       <input type="submit" name="submit" value="Record Vote" disabled="true">
                    </c:if>
                </form>
            </c:if>
        </c:if>
        <c:if test="${!fullMember}">
            Sorry only full members of the collaboration may vote in this election. If you think you
            are seeing this message in error please contact <a href="${admin_email}">${admin_name}</a>
        </c:if>
    </body>
</html>
