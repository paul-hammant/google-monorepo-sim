from python.components.diphthongs.diphthongs import classify, list_all


def test_classify_known():
    assert classify("ai") == "ai: a → i"
    assert classify("ou") == "ou: o → u"


def test_classify_unknown():
    assert classify("zz") == "zz: not a diphthong"


def test_list_all():
    result = list_all()
    assert len(result) == 5
    assert "ai" in result
    assert "ou" in result
