mkdir -p bin
echo '#!/usr/bin/env node' > bin/pert
coffee -b -c --no-header -p src/pert.coffee >> bin/pert
chmod +x bin/pert
