-- Seed some example features for Feature Management UI
INSERT INTO features(id,name,description,enabled,created_at,updated_at) VALUES
('feature-1','New Dashboard','Enable redesigned dashboard for select users',1,datetime('now','-2 days'),datetime('now','-2 days')),
('feature-2','Beta Reports','Experimental reporting module',0,datetime('now','-1 days'),datetime('now','-1 days')),
('feature-3','Quick-Order','Faster ordering flow for power users',1,datetime('now'),datetime('now'));
