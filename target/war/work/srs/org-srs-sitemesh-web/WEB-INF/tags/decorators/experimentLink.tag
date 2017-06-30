<%@tag description="header decorator" pageEncoding="UTF-8"%>
<%@taglib prefix="srs_utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<c:if test="${ ! empty appModes }">
    <c:if test="${ ! empty appModes.experiment }" >
        <c:if test="${ fn:length(appModes.experiment.allowedValuesList) > 1 }" >
            Project: <srs_utils:modeChooser href="${pageContext.request.contextPath}" mode="experiment"/>
        </c:if>
    </c:if>
</c:if>