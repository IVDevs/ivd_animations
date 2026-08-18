(function () {
  var searchInput = document.getElementById('search');
  var results = document.getElementById('results');
  var categoriesEl = document.getElementById('categories');
  var closeBtn = document.getElementById('close');
  var cancelBtn = document.getElementById('cancelAnim');

  var MAX_RESULTS = 60;

  var categories = window.IVD_ANIMATIONS || [];
  var activeDict = categories.length ? categories[0].dict : null;

  var flat = [];
  categories.forEach(function (entry) {
    entry.clips.forEach(function (clip) {
      flat.push({
        dict: entry.dict,
        dictLabel: entry.dictLabel,
        name: clip.name,
        label: clip.label,
        searchText: (entry.dictLabel + ' ' + clip.label + ' ' + entry.dict + ' ' + clip.name).toLowerCase(),
      });
    });
  });

  function playClip(dict, name) {
    Events.Call('ivd_anim:playFromMenu', [dict, name]);
  }

  function renderResults(list, truncated) {
    results.innerHTML = '';

    if (!list.length) {
      results.innerHTML = '<div class="results-empty">No matching animations.</div>';
      return;
    }

    list.forEach(function (item) {
      var row = document.createElement('div');
      row.className = 'result-row';

      var clip = document.createElement('div');
      clip.className = 'result-clip';
      clip.textContent = item.label;

      var dict = document.createElement('div');
      dict.className = 'result-dict';
      dict.textContent = item.dictLabel;

      row.appendChild(clip);
      row.appendChild(dict);

      row.addEventListener('click', function () {
        playClip(item.dict, item.name);
      });

      results.appendChild(row);
    });

    if (truncated) {
      var more = document.createElement('div');
      more.className = 'results-empty';
      more.textContent = 'Showing first ' + MAX_RESULTS + ' results — keep typing to narrow down.';
      results.appendChild(more);
    }
  }

  function renderCategory(dict) {
    var entry = categories.filter(function (c) { return c.dict === dict; })[0];
    if (!entry) {
      renderResults([], false);
      return;
    }

    renderResults(entry.clips.map(function (clip) {
      return {
        dict: entry.dict,
        dictLabel: entry.dictLabel,
        name: clip.name,
        label: clip.label,
      };
    }), false);
  }

  function renderCategoryList() {
    categoriesEl.innerHTML = '';

    categories.forEach(function (entry) {
      var row = document.createElement('div');
      row.className = 'category-row' + (entry.dict === activeDict ? ' active' : '');

      var label = document.createElement('span');
      label.textContent = entry.dictLabel;
      row.appendChild(label);

      var count = document.createElement('span');
      count.className = 'category-count';
      count.textContent = '(' + entry.clips.length + ')';
      row.appendChild(count);

      row.addEventListener('click', function () {
        activeDict = entry.dict;
        searchInput.value = '';
        renderCategoryList();
        renderCategory(activeDict);
      });

      categoriesEl.appendChild(row);
    });
  }

  function search(query) {
    query = query.trim().toLowerCase();

    if (!query) {
      categoriesEl.classList.remove('hidden');
      if (activeDict) {
        renderCategory(activeDict);
      } else {
        renderResults([], false);
      }
      return;
    }

    categoriesEl.classList.add('hidden');

    var matches = flat.filter(function (item) {
      return item.searchText.indexOf(query) !== -1;
    });

    renderResults(matches.slice(0, MAX_RESULTS), matches.length > MAX_RESULTS);
  }

  searchInput.addEventListener('input', function () {
    search(searchInput.value);
  });

  closeBtn.addEventListener('click', function () {
    Events.Call('ivd_anim:closeMenu', []);
  });

  cancelBtn.addEventListener('click', function () {
    Events.Call('ivd_anim:cancel', []);
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      Events.Call('ivd_anim:closeMenu', []);
    }
  });

  renderCategoryList();
  search('');
  searchInput.focus();
})();
