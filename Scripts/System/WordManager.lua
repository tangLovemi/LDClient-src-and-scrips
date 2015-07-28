module("WordManager", package.seeall)

local m_words = nil;

function loadWords(fileName)
    local text = SJTxtFile:openFile(PATH_RES_DATA .. fileName);
    m_words = json.decode(text).words;
end

function getWord(index)
    return m_words[index];
end