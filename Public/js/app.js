function login() {
    var data = {
        username: $("input[name=username]").val(),
        password: $("input[name=password]").val(),
        email: $("input[name=email]").val()
    };
    var register = $("input[name=email]").length;
    $.ajax({
        type: "POST",
        url: register ? "/api/register" : "/api/login",
        data: data,
        success: function(r) {
            if (r.status == "ok") {
                document.cookie = 'auth=' + r.auth + '; expires=Thu, 1 Aug 2030 20:00:00 UTC; path=/';
                window.location.href = "/";
            } else {
                $("#errormsg").html(r.message);
            }
        }
    });
    return false;
}

function submit() {
    var data = {
        news_id: $("input[name=news_id]").val(),
        title: $("input[name=title]").val(),
        url: $("input[name=url]").val(),
        text: $("textarea[name=text]").val(),
        apisecret: $("input[name=apisecret]").val()
    };
    var del = $("input[name=del]").length && $("input[name=del]").attr("checked");
    $.ajax({
        type: "POST",
        url: del ? "/api/delnews" : "/api/submit",
        data: data,
        success: function(r) {
            if (r.status == "ok") {
                if (r.news_id === -1 || r.news_id === undefined) {
                    window.location.href = "/";
                } else {
                    window.location.href = "/news/"+r.news_id;
                }
            } else {
                $("#errormsg").html(r.message);
            }
        }
    });
    return false;
}