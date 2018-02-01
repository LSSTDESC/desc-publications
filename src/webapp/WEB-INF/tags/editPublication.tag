<%-- 
    Document   : editPublication
    Created on : Aug 8, 2017, 12:30:24 PM
    Author     : chee
--%>
<%@tag pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://srs.slac.stanford.edu/time" prefix="time"%>
<%@taglib uri="http://srs.slac.stanford.edu/GroupManager" prefix="gm"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<script src="js/jquery-1.11.1.min.js"></script>
<script src="js/jquery.validate.min.js"></script>

<%@attribute name="paperid" required="true"%>

<%--
<%@attribute name="swgid" required="false"%>

<c:set var="paperid" value="${param.paperid}"/>
<c:set var="swgid" value="${param.swgid}"/> --%>

<c:set var="paperleads" value="paper_leads_${paperid}"/> 
 <sql:query var="pubtypes">
     select pubtype from descpub_publication_types order by pubtype
 </sql:query>

 <sql:query var="pubs">
  select paperid, state, title, short_title, pubtype, summary, to_char(createdate,'yyyy-mon-dd') added, to_char(modifydate,'yyyy-mon-dd') moddate, builder_eligible, key_paper,
  passed_internal_review, arxiv, published_reference, project_id, short_title from descpub_publication where paperid = ?
    <sql:param value="${paperid}"/>
 </sql:query>
 
 <c:set var="pubtype" value="${pubs.rows[0].pubtype}"/>
    
<sql:query var="states">
    select state from descpub_publication_states order by state
</sql:query>
     
<sql:query var="fi">
    select pb.metaid, me.data, me.label, me.datatype, pb.sqlstr, pb.multiplevalues, pb.formposition from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
    where pb.pubtype = ? order by pb.formposition
    <sql:param value="${pubtype}"/>
</sql:query>
    
    
 <h1>pubtype ${pubtype}</h1>
<sql:query var="results">
    select * from descpub_publication where paperid = ?
    <sql:param value="${param.paperid}"/>
</sql:query>
    
    
<h3>DESC-${param.paperid} Title: ${pubs.rows[0].title} </h3>
    Project Id: <a href="show_project.jsp?projid=${pubs.rows[0].project_id}">${pubs.rows[0].project_id}</a> &nbsp; &nbsp; Added: ${pubs.rows[0].added}
    <c:if test="${!empty pubs.rows[0].moddate}">
        &nbsp; &nbsp;Last Modified: ${pubs.rows[0].moddate} &nbsp; &nbsp; &nbsp; &nbsp;
    </c:if>
        [ Placeholder for link to internal review ]
    <p/> 
    
    <form action="editPublication.jsp?paperid=${param.paperid}" method="post">
        <c:forEach var="x" items="${fi.rows}">
            <c:if test="${!empty x.fieldexplanation}">
                <p id="pagelabel">  <c:out value="${x.fieldexplanation}"/></p>
            </c:if>
            <c:if test="${x.datatype == 'string'}">
                 ${x.label}  <input type="text" value="${results.rows[0][x.data]}" name="${x.data}"/>
                 <p></p>
            </c:if>
            <c:if test="${x.datatype == 'dropbox'}">
                <sql:query var="res">
                    select metavalue, defaultvalue from descpub_metadata_enum where metaid = ?
                    <sql:param value="${x.metaid}"/>
               </sql:query>
               ${x.label}:  
               <select name="${x.data}" ${required}>
                    <c:forEach var="erow" items="${res.rows}">
                        <option value="${erow.metavalue}" <c:if test="${results.rows[0][x.data] == erow.metavalue}">selected</c:if> > ${erow.metavalue}</option>
                    </c:forEach>
                </select> 
                <p></p>
            </c:if>
            <c:if test="${x.datatype == 'checkbox'}">
                <c:set var="required" value="${x.required == 'required' ? required : ''}"/>
                <sql:query var="enums">
                    select * from descpub_metadata_enum where metaid = ?
                    <sql:param value="${x.metaid}"/>
                </sql:query>
                <c:forEach var="chkbx" items="${enums.rows}">
                  ${chkbx.metavalue} <input type="checkbox" name="${x.data}" value="${chkbx.metavalue}" ${required}/><br/>
                </c:forEach>
                <p></p>
            </c:if>       
            <c:if test="${x.datatype == 'list'}">
                 <c:set var="selected" value=""/>
                 <sql:query var="res">
                    ${x.sqlstr}
                 </sql:query>   
                 <c:if test="${fn:contains(x.data,'current_institution')}">
                     <select name="${x.data}" ${required}>
                         <c:forEach var="in" items="${res.rows}">
                             <option value="${in['institution']}"> ${in['institution'] == results.rows[0][x.data] ? selected : ''} </option>
                         </c:forEach>
                     </select> 
                </c:if>

                <c:if test="${x.data == 'state'}">
                    ${x.label}
                     <select name="${x.data}" ${required}>
                         <c:forEach var="st" items="${res.rows}">
                           <option value="${st['state']}" <c:if test="${results.rows[0][x.data] == st['state']}">selected</c:if> > ${st['state']}</option>
                         </c:forEach>
                     </select>
                </c:if>
                 <p></p>
            </c:if>
            <c:if test="${x.datatype == 'textarea'}">
                ${x.label}:<br/><textarea name="${x.data}" ${x.required}>${results.rows[0][x.data]}</textarea><br/>
                 <p></p>
            </c:if>
            
        </c:forEach>
        <input type="submit" name="submit" value="update"/>
    </form>
    
    
    
  
 